module Translatomatic
  # Translates resource files from one language to another.
  class FileTranslator
    # @return [Translatomatic::Translator] Translator object
    attr_reader :translator

    # Create a new FileTranslator instance
    #
    # @param options [Hash<Symbol,Object>] converter and/or
    #   provider options.
    def initialize(options = {})
      @dry_run = options[:dry_run]
      @in_place = options[:in_place]
      @translator = Translator.new(options)
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

      strings = strings_from_file(file)
      value_map = init_value_map(file)
      collection = @translator.translate(strings, to_locale)
      file.properties.each do |key, value|
        keys = value_map[value.to_s]
        translation = collection.get(value) # best translation
        new_value = translation ? translation.result.to_s : nil
        keys.each { |key| file.set(key, new_value) }
      end
      file.locale = to_locale
      file
    end

    # Translates a resource file and writes results to a target
    # resource file. The path of the target resource file is
    # automagically determined.
    #
    # @param source [Translatomatic::ResourceFile] The source
    # @param to_locale [String] The target locale, e.g. "fr"
    # @return [Translatomatic::ResourceFile] The translated resource file
    def translate_to_file(source, to_locale)
      # Automatically determines the target filename based on target locale.
      target = resource_file(source)
      to_locale = parse_locale(to_locale)

      if @in_place
        log.info(t('file_translator.translating_in_place',
                   source: target, source_locale: target.locale,
                   target_locale: to_locale))
      else
        target_path = source.locale_path(to_locale)
        return if target_path == source.path

        # make a copy of source and change the path
        target = resource_file(source.path, target.options)
        target.locale = source.locale # updated by translate() later
        target.path = target_path

        log.info(t('file_translator.translating',
                   source: source, source_locale: source.locale,
                   target: target, target_locale: to_locale))
      end

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
    define_option :no_database, type: :boolean, default: false,
                                desc: t('file_translator.no_database')
    define_option :in_place, type: :boolean, command_line_only: true,
                             default: false,
                             desc: t('file_translator.in_place')

    def strings_from_file(file)
      strings = []
      file.properties.each do |key, value|
        string = string(value, file.locale)
        string.preserve_regex = file.variable_regex
        string.context = file.get_context(key)
        strings << string
      end
      strings
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

    def parse_locale(locale)
      Translatomatic::Locale.parse(locale)
    end
  end
end
