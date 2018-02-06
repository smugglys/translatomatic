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
      unless @dry_run
        collection = @translator.translate(texts, to_locale)
        update_properties(file, to_locale, collection)
      end
      file
    end

    # Translates a resource file and writes results to a target
    # resource file. The path of the target resource file is
    # automagically determined.
    # @param source [ResourceFile] The source
    # @param to_locale [String] The target locale, e.g. "fr"
    # @return [ResourceFile] The translated resource file
    def translate_to_file(source, to_locale)
      target = translation_target_file(source, to_locale)
      return source unless target
      translate(target, to_locale)
      save_resource_file(target)
    end

    private

    include Translatomatic::Util
    include Translatomatic::DefineOptions

    define_option :in_place, type: :boolean, command_line_only: true,
                             default: false,
                             desc: t('file_translator.in_place')

    # Update file properties from the given translation collection
    def update_properties(file, to_locale, collection)
      value_map = init_value_map(file)
      file.properties.each_value do |value|
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

    # Create a target file to write for the given source file.
    # @param source [ResourceFile] Source resource file
    # @param to_locale [Locale] Target locale
    # @return [ResourceFile] Target file, or nil if we shouldn't translate
    def translation_target_file(source, to_locale)
      if @in_place
        source
      else
        target_path = source.locale_path(to_locale)
        # don't overwrite source unless using @in_place
        return nil if target_path == source.path
        target = resource_file(source.path, source.options)
        target.path = target_path
        target
      end
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
