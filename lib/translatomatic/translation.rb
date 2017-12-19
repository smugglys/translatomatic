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

  # translate contents of source_file to the list of locales.
  # writes output files corresponding to each locale.
  # returns a list of translated resource files
  def translate(source_file, locales)
    locales = [locales] unless locales.kind_of?(Array)
    locales = locales.collect { |i| i.kind_of?(String) ? parse_locale(i) : i }

    source = Translatomatic::ResourceFile.load(source_file)
    targets = []
    log.debug("source: #{source}")
    locales.each do |locale|
      target_file = source.locale_path(locale)
      if target_file.exist?
        # open existing target file
        target = Translatomatic::ResourceFile.load(target_file, locale)
      else
        # create a target file of the same type as the source
        target = source.class.new(target_file, locale)
      end
      targets << target
      log.debug("target: #{target}")

      if source.locale.language == target.locale.language
        # copy all properties to target
        source.properties.each do |key, value|
          target.set(key, value)
        end
      else
        # perform translation
        # TODO: should untranslated properties be removed?
        # TODO: should existing translations be imported to the database?
        properties = translate_properties(source.properties, source.locale, target.locale)
        properties.each do |key, value|
          target.set(key, value)
        end
      end
      target.save
    end
    targets
  end

  class TranslationSet

    def initialize(properties)
      # find strings to send to translator
      # create a list of key, value. doesn't rely on hash ordering
      @key_values = []
      @properties = properties.dup
      @value_to_key = {}
      properties.each do |key, value|
        @key_values << [key, value]
        @value_to_key[value] = key
      end
    end

    def strings
      @key_values.collect { |k,v| v }
    end

    # update data with a list of translated strings (from translator)
    # the strings must have the same length and order as @key_values
    def update_strings(strings)
      raise "strings length mismatch" unless strings.length == @key_values.length
      strings = strings.dup
      @key_values.each do |key, value|
        new_value = strings.shift
        @properties[key] = new_value
      end
    end

    # update data with list of texts from database
    def update_texts(texts)
      texts.each do |t|
        original = t.from_text.value
        translated = t.value
        key = @value_to_key[original]
        raise "no key mapping for text '#{original}'" unless key
        @properties[key] = translated

        # remove entry from @key_values
        @key_values = @key_values.select { |k,v| k != key }
      end
    end

    def to_hash
      @properties
    end
  end

  # translate the hash of properties from one locale to another.
  # returns translated properties.
  # uses existing translations from the database if available
  def translate_properties(properties, from_locale, to_locale)
    set = TranslationSet.new(properties)

    # find translations in database first
    texts = find_database_translations(set, from_locale, to_locale)
    set.update_texts(texts)

    # send remaining unknown strings to translator
    if set.strings.length > 0
      translated = @translator.translate(set.strings, from_locale, to_locale)
      set.update_strings(translated)
    end
    set.to_hash
  end

  private

  def find_database_translations(set, from_locale, to_locale)
    from = db_locale(from_locale)
    to = db_locale(to_locale)
    translations = Translatomatic::Model::Text.where({
      locale: to,
      from_texts_texts: { locale_id: from, value: set.strings }
    }).joins(:from_text)
  end

  def db_locale(locale)
    Translatomatic::Model::Locale.from_tag(locale)
  end
end
