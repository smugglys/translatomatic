class Translatomatic::Converter
  include Translatomatic::Util

  # Create a converter to translate files
  #
  # @param options A hash of converter and/or translator options.
  def initialize(options = {})
    @translator = options[:translator]
    if @translator.kind_of?(String) || @translator.kind_of?(Symbol)
      klass = Translatomatic::Translator.find(@translator)
      @translator = klass.new(options)
    end
    @translator ||= Translatomatic::Translator.default
    raise "translator required" unless @translator
  end

  # Translate contents of source_file to the target locale.
  # Automatically determines the target filename based on target locale.
  #
  # @param [String, Translatomatic::ResourceFile] source_file File to translate
  # @param [String] to_locale The target locale, e.g. "fr"
  # @return [Translatomatic::ResourceFile] The translated resource file
  def translate(source_file, to_locale)
    if source_file.kind_of?(Translatomatic::ResourceFile::Base)
      source = source_file
    else
      source = Translatomatic::ResourceFile.load(source_file)
      raise "unsupported file type #{source_file}" unless source
    end

    log.debug("source: #{source}")
    to_locale = parse_locale(to_locale)
    target_file = source.locale_path(to_locale)
    if target_file.exist?
      # open existing target file
      target = Translatomatic::ResourceFile.load(target_file, to_locale)
    else
      # create a target file of the same type as the source
      target = source.class.new(target_file, to_locale)
    end
    log.debug("target: #{target}")
    translate_to_target(source, target)
  end

  # Translates a resource file and writes results to a target resource file
  #
  # @param source [Translatomatic::ResourceFile] The source
  # @param target [Translatomatic::ResourceFile] The file to write
  # @return [Translatomatic::ResourceFile] The translated resource file
  def translate_to_target(source, target)
    # perform translation
    # TODO: should untranslated properties be removed?
    # TODO: should existing translations be imported to the database?
    properties = translate_properties(source.properties, source.locale, target.locale)
    properties.each do |key, value|
      target.set(key, value)
    end
    target.save
    target
  end

  # Translate values in the hash of properties.
  # Uses existing translations from the database if available.
  #
  # @param [Hash] properties Text to translate
  # @param [String, Locale] from_locale The locale of the given properties
  # @param [String, Locale] to_locale The target locale for translations
  # @return [Hash] Translated properties
  def translate_properties(properties, from_locale, to_locale)
    from_locale = parse_locale(from_locale)
    to_locale = parse_locale(to_locale)

    # sanity check
    return properties if from_locale.language == to_locale.language

    result = Translatomatic::TranslationResult.new(properties,
      from_locale, to_locale)

    # find translations in database first
    texts = find_database_translations(result)
    result.update_db_strings(texts)

    # send remaining unknown strings to translator
    if result.has_untranslated_strings?
      translated = @translator.translate(result.original_strings, from_locale, to_locale)
      result.update_strings(translated)
      save_database_translations(result, translated)
    end

    log.debug("translation: from db: #{texts.length}, translator: #{result.original_strings.length}")

    result.properties
  end

  private

  def save_database_translations(result, translated_list)
    translated_list = translated_list.dup

    from = db_locale(result.from_locale)
    to = db_locale(result.to_locale)
    result.original_strings.each do |original|
      translated = translated_list.shift
      original_text = Translatomatic::Model::Text.find_or_create_by!({
        locale: from,
        value: original
        })
      result_text = Translatomatic::Model::Text.find_or_create_by!({
        locale: to,
        value: translated,
        from_text: original_text,
        translator: @translator.class.name.demodulize,
        })
    end
  end

  def find_database_translations(result)
    from = db_locale(result.from_locale)
    to = db_locale(result.to_locale)
    translations = Translatomatic::Model::Text.where({
      locale: to,
      from_texts_texts: { locale_id: from, value: result.original_strings }
    }).joins(:from_text)
  end

  def db_locale(locale)
    Translatomatic::Model::Locale.from_tag(locale)
  end
end
