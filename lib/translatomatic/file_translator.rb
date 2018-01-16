module Translatomatic
  # The file translator ties together functionality from translators,
  # resource files, and the database to convert files from one
  # language to another.
  class FileTranslator
    # @return [Array<Translatomatic::Model::Text>] A list of
    #   translations saved to the database
    attr_reader :db_translations

    # Create a converter to translate files
    #
    # @param options [Hash<Symbol,Object>] converter and/or
    #   translator options.
    def initialize(options = {})
      @dry_run = options[:dry_run]
      @listener = options[:listener]
      @translators = resolve_translators(options)
      raise t('file_translator.translator_required') if @translators.empty?
      @translators.each { |i| i.listener = @listener } if @listener

      # use database by default if we're connected to a database
      use_db = options.fetch(:use_database, true)
      @use_db = use_db && ActiveRecord::Base.connected?
      log.debug(t('file_translator.database_disabled')) unless @use_db

      @db_translations = []
      @translations = {} # map of original text to Translation
    end

    # @return [Translatomatic::TranslationStats] Translation statistics
    def stats
      Translatomatic::TranslationStats.new(@translations)
    end

    # Translate properties of source_file to the target locale.
    # Does not write changes to disk.
    #
    # @param file [String, Translatomatic::ResourceFile] File to translate
    # @param to_locale [String] The target locale, e.g. "fr"
    # @return [Translatomatic::ResourceFile] The translated resource file
    def translate(file, to_locale)
      file = resource_file(file)
      to_locale = parse_locale(to_locale)

      # do nothing if target language is the same as source language
      return file if file.locale.language == to_locale.language
      result = Translatomatic::TranslationResult.new(file, to_locale)

      # translate using strings from the database first
      each_translator(result) { translate_properties_with_db(result) }
      # send remaining unknown strings to translator
      each_translator(result) { translate_properties_with_translator(result) }

      log.debug(stats)
      @listener.untranslated_texts(result.untranslated) if @listener

      result.apply!
      file.properties = result.properties
      file.locale = to_locale
      file
    end

    # Translates a resource file and writes results to a target
    # resource file. The path of the target resource file is
    # automatically determined.
    #
    # @param source [Translatomatic::ResourceFile] The source
    # @param to_locale [String] The target locale, e.g. "fr"
    # @return [Translatomatic::ResourceFile] The translated resource file
    def translate_to_file(source, to_locale)
      # Automatically determines the target filename based on target locale.
      source = resource_file(source)
      target = Translatomatic::ResourceFile.load(source.path)
      target.locale = source.locale
      target.path = source.locale_path(to_locale)
      return if target.path == source.path

      log.info(t('file_translator.translating', source: source,
                                                source_locale: source.locale,
                                                target: target,
                                                target_locale: to_locale))
      translate(target, to_locale)
      unless @dry_run
        target.path.parent.mkpath
        target.save
      end
      target
    end

    private

    include Translatomatic::Util
    include Translatomatic::DefineOptions

    define_option :dry_run, type: :boolean, aliases: '-n',
                            desc: t('file_translator.dry_run'),
                            command_line_only: true
    define_option :use_database, type: :boolean, default: true,
                                 desc: t('file_translator.use_database')

    def each_translator(result)
      @translators.each do |translator|
        break if result.untranslated.empty?
        @current_translator = translator
        yield
      end
    end

    # Attempt to restore interpolated variable names in the translation.
    # If variable names cannot be restored, sets the translation result to nil.
    # @param result [Translatomatic::TranslationResult] translation result
    # @param translation [Translatomatic::Translation] translation
    # @return [void]
    def restore_variables(result, translation)
      file = result.file
      return unless file.class.supports_variable_interpolation?
      unless translation.restore_variables(file.variable_regex)
        # unable to restore interpolated variable names
        translator = @current_translator.name
        failed_string = translation.result
        msg = "#{translator}: unable to restore variables: #{failed_string}"
        log.debug(msg)
        translation.result = nil # mark result as invalid
      end
    end

    # rubocop:disable Style/ClassCheck
    def resource_file(path)
      if path.kind_of?(Translatomatic::ResourceFile::Base)
        path
      else
        file = Translatomatic::ResourceFile.load(path)
        raise t('file.unsupported', file: path) unless file
        file
      end
    end

    # update result with translations from the database.
    def translate_properties_with_db(result)
      db_texts = []
      unless database_disabled?
        translations = []
        untranslated = hashify(result.untranslated)
        db_texts = find_database_translations(result, result.untranslated.to_a)
        db_texts.each do |db_text|
          from_text = db_text.from_text.value
          original = untranslated[from_text]
          next unless original
          translation = translation(original, db_text.value, true)
          restore_variables(result, translation)
          translations << translation
        end

        result.add_translations(translations)
        log.debug("found #{translations.length} translations in database")
        @listener.translated_texts(translations) if @listener
      end
      db_texts
    end

    # update result with translations from the translator.
    def translate_properties_with_translator(result)
      untranslated = result.untranslated.to_a.select { |i| translatable?(i) }
      translated = []
      if !untranslated.empty? && !@dry_run
        untranslated_strings = untranslated.collect(&:to_s)
        translator = @current_translator
        log.debug("translating: #{untranslated} with #{translator.name}")
        translated = translator.translate(untranslated_strings,
                                          result.from_locale, result.to_locale)

        # sanity check: we should have a translation for each string
        unless translated.length == untranslated.length
          raise t('translator.invalid_response')
        end

        # create list of translations, filtering out invalid translations
        translations = []
        untranslated.zip(translated).each do |from, to|
          next unless to
          translation = translation(from, to, false)
          restore_variables(result, translation)
          translations << translation
        end

        result.add_translations(translations)
        save_database_translations(result, translations)
      end
      translated
    end

    def translation(from, to, from_database = false)
      translator = @current_translator.name
      t = Translatomatic::Translation.new(from, to, translator, from_database)
      @translations[from] = t
    end

    def database_disabled?
      !@use_db
    end

    def parse_locale(locale)
      Translatomatic::Locale.parse(locale)
    end

    def translatable?(string)
      # don't translate numbers
      string && !string.match(/\A\s*\z/) && !string.match(/\A[\d,]+\z/)
    end

    def save_database_translations(result, translations)
      return if database_disabled?
      ActiveRecord::Base.transaction do
        from = db_locale(result.from_locale)
        to = db_locale(result.to_locale)
        translations.each do |translation|
          next if translation.result.nil? # skip invalid translations
          save_database_translation(from, to, translation)
        end
      end
    end

    def save_database_translation(from_locale, to_locale, translation)
      original_text = Translatomatic::Model::Text.find_or_create_by!(
        locale: from_locale,
        value: translation.original.to_s
      )

      text = Translatomatic::Model::Text.find_or_create_by!(
        locale: to_locale,
        value: translation.result.to_s,
        from_text: original_text,
        translator: @current_translator.name
      )
      @db_translations += [original_text, text]
      text
    end

    def find_database_translations(result, untranslated)
      from = db_locale(result.from_locale)
      to = db_locale(result.to_locale)

      Translatomatic::Model::Text.where(
        locale: to,
        translator: @current_translator.name,
        from_texts_texts: {
          locale_id: from,
          # convert untranslated set to strings
          value: untranslated.collect(&:to_s)
        }
      ).joins(:from_text)
    end

    def resolve_translators(options)
      Translatomatic::Translator.resolve(options[:translator], options)
    end

    def db_locale(locale)
      Translatomatic::Model::Locale.from_tag(locale)
    end
  end
end
