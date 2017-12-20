class Translatomatic::Translation
  include Translatomatic::Util

=begin
  Method:
  - find input file(s) to translate, and associated output file(s)
  - get translator to use, specified in options or one that can work
  - read input files and find all strings to translate
  - get existing translations from database
  - translate translations not in database
  - write translated target files
=end

  def initialize(options = {})
    @translator = options[:translator]
    if @translator.kind_of?(String) || @translator.kind_of?(Symbol)
      @translator = Translatomatic::Translator.find(@translator)
    end
  end

  # translate contents of source_file to the target locale
  # writes output files corresponding the target locale
  # returns the translated resource file
  def translate(source_file, to_locale)
    to_locale = parse_locale(to_locale)
    source = Translatomatic::ResourceFile.load(source_file)
    log.debug("translating source: #{source}")
    target_file = source.locale_path(to_locale)
    if target_file.exist?
      # open existing target file
      target = Translatomatic::ResourceFile.load(target_file, to_locale)
    else
      # create a target file of the same type as the source
      target = source.class.new(target_file, to_locale)
    end
    log.debug("target: #{target}")

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

  # translate the hash of properties.
  # returns translated properties.
  # uses existing translations from the database if available
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
      translated = @translator.translate(result.original_strings)
      result.update_strings(translated)
      save_database_translations(result, translated)
    end
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
