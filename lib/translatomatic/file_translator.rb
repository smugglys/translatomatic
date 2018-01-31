module Translatomatic
  # Translates resource files from one language to another.
  class FileTranslator
    # @return [Translatomatic::Translator] Translator object
    attr_reader :translator

    # Create a new FileTranslator instance
    # @param options [Hash<Symbol,Object>] converter and/or
    #   provider options.
    def initialize(options = {})
      @dry_run = options[:dry_run]
      @in_place = options[:in_place]
      @translator = Translator.new(options)
    end

    # Translate properties of file to the target locale.
    # Does not write changes to disk.
    # @param file [String, Translatomatic::ResourceFile] File to translate
    # @param to_locale [String] The target locale, e.g. "fr"
    # @return [Translatomatic::ResourceFile] The translated resource file
    def translate(file, to_locale)
      file = resource_file(file)
      to_locale = build_locale(to_locale)

      # do nothing if target language is the same as source language
      return file if file.locale.language == to_locale.language

      texts = texts_from_file(file)
      collection = @translator.translate(texts, to_locale)
      update_properties(file, to_locale, collection)
      file
    end

    # Translates a resource file and writes results to a target
    # resource file. The path of the target resource file is
    # automagically determined.
    # @param source [ResourceFile] The source
    # @param to_locale [String] The target locale, e.g. "fr"
    # @return [ResourceFile] The translated resource file
    def translate_to_file(source, to_locale)
      translated = translate_to_files(source, to_locale)
      translated[0]
    end

    # Translates one or more source files to one or more locales and
    # writes results to target resource files. The path of the target
    # resource files are automatically determined.
    # @param sources [Array<ResourceFile>] Source files to translate
    # @param to_locales [Array<String>] Target locales
    # @return [Array<ResourceFile>] Translated resource files
    def translate_to_files(sources, to_locales)
      sources = [sources] unless sources.is_a?(Array)
      to_locales = [to_locales] unless to_locales.is_a?(Array)
      texts = sources.collect { |i| texts_from_file(i) }.flatten
      collection = @translator.translate(texts, to_locales)
      translated = []
      sources.each do |source|
        to_locales.each do |to_locale|
          translated << translate_file(source, to_locale, collection)
        end
      end
      translated.compact
    end

    private

    include Translatomatic::Util
    include Translatomatic::DefineOptions

    define_option :dry_run, type: :boolean, aliases: '-n',
                            desc: t('file_translator.dry_run'),
                            command_line_only: true
    define_option :in_place, type: :boolean, command_line_only: true,
                             default: false,
                             desc: t('file_translator.in_place')

    # translates a resource file using the given translation collection
    # saves to target
    def translate_file(source, to_locale, collection)
      to_locale = build_locale(to_locale)
      target = translation_target_file(source, to_locale)
      return source unless target
      update_properties(target, to_locale, collection)
      save_resource_file(target)
    end
  
    # Update file properties from the given translation collection
    def update_properties(file, to_locale, collection)
      value_map = init_value_map(file)
      file.properties.each do |_key, value|
        keys = value_map[value.to_s]
        translation = collection.get(value, to_locale) # best translation
        new_value = translation ? translation.result.to_s : nil
        keys.each { |key| file.set(key, new_value) }
      end
      file.locale = to_locale
    end

    def save_resource_file(file)
      unless @dry_run
        file.path.parent.mkpath
        file.save
      end
      file
    end

    # Determine the target file to write for the given source file
    # @param source [ResourceFile] Source resource file
    # @param to_locale [Locale] Target locale
    # @return [ResourceFile] Target resource file, or nil if no target
    def translation_target_file(source, to_locale)
      if @in_place
        target = resource_file(source)
        log.info(t('file_translator.translating_in_place',
                   source: target, source_locale: target.locale,
                   target_locale: to_locale))
      else
        target_path = source.locale_path(to_locale)
        # don't overwrite source unless using @in_place
        return nil if target_path == source.path

        # make a copy of source and change the path
        target = resource_file(source.path, source.options)
        target.locale = source.locale # updated by translate() later
        target.path = target_path

        log.info(t('file_translator.translating',
                   source: source, source_locale: source.locale,
                   target: target, target_locale: to_locale))
      end
      target
    end

    def texts_from_file(file)
      texts = []
      file.properties.each do |key, value|
        text = build_text(value, file.locale)
        text.preserve_regex = file.variable_regex
        text.context = file.get_context(key)
        texts << text
      end
      texts
    end

    # set up a mapping from property value -> key list
    def init_value_map(file)
      value_map = {}
      file.properties.each do |key, value|
        keylist = (value_map[value.to_s] ||= [])
        keylist << key
      end
      value_map
    end

    def resource_file(path, options = {})
      if path.is_a?(Translatomatic::ResourceFile::Base)
        path
      else
        file = Translatomatic::ResourceFile.load(path, options)
        raise t('file.unsupported', file: path) unless file
        file
      end
    end
  end
end
