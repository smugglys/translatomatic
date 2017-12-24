class Translatomatic::Converter

  class << self
    attr_reader :options
    private
    include Translatomatic::DefineOptions
  end

  define_options(
    { name: :translator, type: :string, aliases: "-t",
      desc: "Translator implementation to use",
      enum: Translatomatic::Translator.names },
    { name: :dry_run, type: :boolean, aliases: "-n", desc:
      "Print actions without performing translations or writing files" }
  )

  # @return [Translatomatic::ConverterStats] translation statistics
  attr_reader :stats

  # Create a converter to translate files
  #
  # @param options A hash of converter and/or translator options.
  def initialize(options = {})
    @dry_run = options[:dry_run]
    @translator = options[:translator]
    @listener = options[:listener]
    if @translator.kind_of?(String) || @translator.kind_of?(Symbol)
      klass = Translatomatic::Translator.find(@translator)
      @translator = klass.new(options)
    end
    raise "translator required" unless @translator
    @translator.listener = @listener if @listener
    @from_db = 0
    @from_translator = 0
  end

  # @return [Translatomatic::ConverterStats] Translation statistics
  def stats
    Translatomatic::ConverterStats.new(@from_db, @from_translator)
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

    to_locale = parse_locale(to_locale)
    target = Translatomatic::ResourceFile.load(source.path)
    target.path = source.locale_path(to_locale)
    target.locale = to_locale
    translate_to_target(source, target)
  end

  # Translates a resource file and writes results to a target resource file
  #
  # @param source [Translatomatic::ResourceFile] The source
  # @param target [Translatomatic::ResourceFile] The file to write
  # @return [Translatomatic::ResourceFile] The translated resource file
  def translate_to_target(source, target)
    # perform translation
    log.info("translating #{source} to #{target}")
    properties = translate_properties(source.properties, source.locale, target.locale)
    target.properties = properties
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

    # find translations in database first
    texts = find_database_translations(result)
    result.update_db_strings(texts)
    @from_db += texts.length
    @listener.translated_texts(texts) if @listener

    # send remaining unknown strings to translator
    # (copy untranslated set from result)
    untranslated = result.untranslated.to_a.select { |i| translatable?(i) }
    @from_translator += untranslated.length
    if !untranslated.empty? && !@dry_run
      translated = @translator.translate(untranslated, from_locale, to_locale)
      result.update_strings(untranslated, translated)
      save_database_translations(result, untranslated, translated)
    end

    log.debug("translations from db: %d translator: %d untranslated: %d" %
      [texts.length, untranslated.length, result.untranslated.length])
    @listener.untranslated_texts(result.untranslated) if @listener

    result.properties
  end

  private

  include Translatomatic::Util

=begin
  def log(level, *args)
    @progressbar.clear if @progressbar
    Translatomatic::Config.instance.logger.send(level, *args)
    @progressbar.refresh if @progressbar
  end
=end

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
      value: t1
    )

    Translatomatic::Model::Text.find_or_create_by!(
      locale: to_locale,
      value: t2,
      from_text: original_text,
      translator: @translator.class.name.demodulize
    )
  end

  def find_database_translations(result)
    from = db_locale(result.from_locale)
    to = db_locale(result.to_locale)

    Translatomatic::Model::Text.where({
      locale: to,
      from_texts_texts: { locale_id: from, value: result.untranslated.to_a }
    }).joins(:from_text)
  end

  def db_locale(locale)
    Translatomatic::Model::Locale.from_tag(locale)
  end
end
