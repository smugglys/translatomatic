# The file translator ties together functionality from translators,
# resource files, and the database to convert files from one
# language to another.
class Translatomatic::FileTranslator
  # @return [Array<Translatomatic::Model::Text>] A list of translations saved to the database
  attr_reader :db_translations

  # Create a converter to translate files
  #
  # @param options [Hash<Symbol,Object>] converter and/or translator options.
  def initialize(options = {})
    @dry_run = options[:dry_run]
    @listener = options[:listener]
    @translators = Translatomatic::Translator.resolve(options[:translator], options)
    raise t('file_translator.translator_required') if @translators.empty?
    @translators.each { |i| i.listener = @listener } if @listener

    # use database by default if we're connected to a database
    use_db = options.include?(:use_database) ? options[:use_database] : true
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

  # Translates a resource file and writes results to a target resource file.
  # The path of the target resource file is automatically determined.
  #
  # @param source [Translatomatic::ResourceFile] The source
  # @param to_locale [String] The target locale, e.g. "fr"
  # @return [Translatomatic::ResourceFile] The translated resource file
  def translate_to_file(source, to_locale)
    # Automatically determines the target filename based on target locale.
    source = resource_file(source)
    target = Translatomatic::ResourceFile.load(source.path)
    target.path = source.locale_path(to_locale)

    log.info(t('file_translator.translating', source: source,
                                              source_locale: source.locale, target: target, target_locale: to_locale))
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

  define_options(
    { name: :dry_run, type: :boolean, aliases: '-n',
      desc: t('file_translator.dry_run'),
      command_line_only: true
    },
    { name: :use_database, type: :boolean, default: true,
      desc: t('file_translator.use_database')
    }
  )

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

    # find variables in the original string
    variables = string_variables(translation.original, file.locale, file)
    # find variables in the translated string
    translated_variables = string_variables(translation.result, result.to_locale, file)

    if variables.length == translated_variables.length
      # we can restore variables. sort by largest offset first.
      # not using translation() method as that adds to @translations hash.
      conversions = variables.zip(translated_variables).collect do |v1, v2|
        Translatomatic::Translation.new(v1, v2)
      end
      conversions.sort_by! { |t| -t.original.offset }
      conversions.each do |conversion|
        v1 = conversion.original
        v2 = conversion.result
        translation.result[v2.offset, v2.length] = v1.value
      end
    else
      # unable to restore interpolated variable names
      log.debug("#{@current_translator.name}: unable to restore variables: #{translation.result}")
      translation.result = nil # mark result as invalid
    end
  end

  def string_variables(value, locale, file)
    string(value, locale).substrings(file.variable_regex)
  end

  def resource_file(path)
    if path.is_a?(Translatomatic::ResourceFile::Base)
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
        next unless untranslated[from_text]
        translation = translation(untranslated[from_text], db_text.value, true)
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
      log.debug("translating: #{untranslated_strings} with #{@current_translator.name}")
      translated = @current_translator.translate(untranslated_strings,
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
      save_database_translations(result, translations) unless database_disabled?
    end
    translated
  end

  def translation(from, to, from_database = false)
    translator = @current_translator.name
    t = Translatomatic::Translation.new(from, to, translator, from_database)
    @translations[from] = t
    t
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

  def db_locale(locale)
    Translatomatic::Model::Locale.from_tag(locale)
  end
end
