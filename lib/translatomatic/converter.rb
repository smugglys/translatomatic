# The converter ties together functionality from translators,
# resource files, and the database to convert files from one
# language to another.
class Translatomatic::Converter
  include Translatomatic::Util
  class << self
    attr_reader :options
    private
    include Translatomatic::DefineOptions
  end

  define_options(
    { name: :translator, type: :string, aliases: "-t",
      desc: t("converter.translator"),
      enum: Translatomatic::Translator.names },
    { name: :dry_run, type: :boolean, aliases: "-n", desc:
      t("converter.dry_run") },
    { name: :use_database, type: :boolean, default: true, desc:
      t("converter.use_database") }
  )

  # @return [Translatomatic::ConverterStats] translation statistics
  attr_reader :stats

  # @return [Array<Translatomatic::Model::Text>] A list of translations saved to the database
  attr_reader :db_translations

  # Create a converter to translate files
  #
  # @param options A hash of converter and/or translator options.
  def initialize(options = {})
    @dry_run = options[:dry_run]
    @translator = options[:translator]
    @listener = options[:listener]

    # use database by default if we're connected to a database
    use_db = options.include?(:use_database) ? options[:use_database] : true
    @use_db = use_db && ActiveRecord::Base.connected?

    log.debug(t("converter.database_disabled")) unless @use_db
    if @translator && !@translator.respond_to?(:translate)
      klass = Translatomatic::Translator.find(@translator)
      @translator = klass.new(options)
    end
    raise t("converter.translator_required") unless @translator
    @translator.listener = @listener if @listener
    @from_db = 0
    @from_translator = 0
    @db_translations = []
  end

  # @return [Translatomatic::ConverterStats] Translation statistics
  def stats
    Translatomatic::ConverterStats.new(@from_db, @from_translator)
  end

  # Translate properties of source_file to the target locale.
  # Does not write changes to disk.
  #
  # @param [String, Translatomatic::ResourceFile] file File to translate
  # @param [String] to_locale The target locale, e.g. "fr"
  # @return [Translatomatic::ResourceFile] The translated resource file
  def translate(file, to_locale)
    file = resource_file(file)
    to_locale = parse_locale(to_locale)

    properties = translate_properties(file.properties, file.locale, to_locale)
    file.properties = properties
    file.locale = to_locale
    file
  end

  # Translates a resource file and writes results to a target resource file
  #
  # @param source [Translatomatic::ResourceFile] The source
  # @param [String] to_locale The target locale, e.g. "fr"
  # @return [Translatomatic::ResourceFile] The translated resource file
  def translate_to_file(source, to_locale)
    # Automatically determines the target filename based on target locale.
    source = resource_file(source)
    target = Translatomatic::ResourceFile.load(source.path)
    target.path = source.locale_path(to_locale)

    log.info(t("converter.translating", source: source, target: target))
    translate(target, to_locale)
    unless @dry_run
      target.path.parent.mkpath
      target.save
    end
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

    # translate using strings from the database first
    db_texts = translate_properties_with_db(result)

    # send remaining unknown strings to translator
    tr_texts = translate_properties_with_translator(result)

    log.debug(t("converter.stats", from_db: db_texts.length,
      from_translator: tr_texts.length,
      untranslated: result.untranslated.length))
    @listener.untranslated_texts(result.untranslated) if @listener

    result.properties
  end

  private

  include Translatomatic::Util

  def resource_file(path)
    if path.kind_of?(Translatomatic::ResourceFile::Base)
      path
    else
      file = Translatomatic::ResourceFile.load(path)
      raise t("converter.file_unsupported", file: path) unless file
      file
    end
  end

  # update result with translations from the database.
  # returns a list of text records from the database.
  def translate_properties_with_db(result)
    db_texts = []
    unless database_disabled?
      untranslated = result.untranslated.to_a
      db_texts = find_database_translations(result, untranslated)

      # find strings in untranslated that were matched in the database
      original_map = {}  # map of original text to translated text from db
      db_texts.each do |db_text|
        original_map[db_text.from_text.value] = db_text
      end
      matched = untranslated.select { |i| original_map[i.value] }
      db_texts = db_texts.collect { |i| i.value }
      result.update_strings(matched, db_texts)
      @from_db += db_texts.length
      @listener.translated_texts(db_texts) if @listener
    end
    db_texts
  end

  # update result with translations from the translator.
  # returns a list of strings from the translator.
  def translate_properties_with_translator(result)
    untranslated = result.untranslated.to_a.select { |i| translatable?(i) }
    translated = []
    @from_translator += untranslated.length
    if !untranslated.empty? && !@dry_run
      translated = @translator.translate(untranslated.collect { |i| i.to_s },
        result.from_locale, result.to_locale)
      result.update_strings(untranslated, translated)
      unless database_disabled?
        save_database_translations(result, untranslated, translated)
      end
    end
    translated
  end

  def database_disabled?
    !@use_db
  end

  def parse_locale(locale)
    Translatomatic::Locale.parse(locale)
  end

  def translatable?(string)
    # don't translate numbers
    !string.empty? && !string.match(/^[\d,]+$/)
  end

  def save_database_translations(result, untranslated, translated)
    ActiveRecord::Base.transaction do
      from = db_locale(result.from_locale)
      to = db_locale(result.to_locale)
      untranslated.zip(translated).each do |t1, t2|
        save_database_translation(from, to, t1, t2)
      end
    end
  end

  def save_database_translation(from_locale, to_locale, t1, t2)
    original_text = Translatomatic::Model::Text.find_or_create_by!(
      locale: from_locale,
      value: t1.to_s
    )

    text = Translatomatic::Model::Text.find_or_create_by!(
      locale: to_locale,
      value: t2.to_s,
      from_text: original_text,
      translator: @translator.name
    )
    @db_translations += [original_text, text]
    text
  end

  def find_database_translations(result, untranslated)
    from = db_locale(result.from_locale)
    to = db_locale(result.to_locale)

    # convert untranslated set to strings
    Translatomatic::Model::Text.where({
      locale: to,
      from_texts_texts: {
        locale_id: from,
        value: untranslated.collect { |i| i.to_s }
      }
    }).joins(:from_text)
  end

  def db_locale(locale)
    Translatomatic::Model::Locale.from_tag(locale)
  end
end
