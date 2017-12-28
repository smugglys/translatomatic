class Translatomatic::Locale

  attr_reader :language
  attr_reader :script
  attr_reader :region

  def self.parse(tag, validate = true)
    locale = tag.kind_of?(Translatomatic::Locale) ? tag : new(tag)
    validate && !locale.valid? ? nil : locale
  end

  def self.default
    DEFAULT_LOCALE
  end

  def initialize(tag)
    data = I18n::Locale::Tag::Rfc4646.tag(tag)
    if data
      @language = data.language
      @script = data.script
      @region = data.region
    end
  end

  def valid?
    # test if lang is a valid ISO 639-1 language
    VALID_LANGUAGES.include?(language)
  end

  def to_s
    [language, script, region].compact.join("-")
  end

  def eql?(other)
    other.kind_of?(Translatomatic::Locale) && other.hash == hash
  end

  def ==(other)
    eql?(other)
  end

  def hash
    [language, script, region].hash
  end

  private

  # list of 2 letter country codes
  VALID_LANGUAGES = ::I18nData.languages.keys.collect { |i| i.downcase }.sort
  DEFAULT_LOCALE = parse(I18n.default_locale)

end
