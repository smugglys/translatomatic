# Represents a locale
# @see https://en.wikipedia.org/wiki/Locale_(computer_software)
class Translatomatic::Locale
  # @return [String] ISO 639-1 language
  attr_reader :language

  # @return [String] ISO 15924 script
  attr_reader :script

  # @return [String] ISO 3166-1 alpha-2 country code
  attr_reader :region

  # Parse the given tag
  # @param tag [String] A string representing a locale
  # @param validate [boolean] If true, return nil if the locale is invalid
  # @return [Locale] A locale object
  def self.parse(tag, validate = true)
    return nil if tag.nil?

    locale = tag
    unless tag.is_a?(Translatomatic::Locale)
      tag = tag.to_s.tr('_', '-')
      locale = new(tag)
    end
    validate && !locale.valid? ? nil : locale
  end

  # @return [Locale] the default locale
  def self.default
    parse(Translatomatic.config.default_locale)
  end

  # @return [Locale] create a new locale object
  def initialize(tag)
    data = I18n::Locale::Tag::Rfc4646.tag(tag)
    if data
      @language = data.language
      @script = data.script
      @region = data.region
    end
  end

  # @return true if language is a valid ISO 639-1 language
  def valid?
    VALID_LANGUAGES.include?(language)
  end

  # @return [String] Locale as a string
  def to_s
    [language, script, region].compact.join('-')
  end

  # @param other [Object] Another object
  # @return [boolean] true if the other object is a {Translatomatic::Locale}
  #   object and has equal language, script and region.
  def eql?(other)
    other.is_a?(Translatomatic::Locale) && other.hash == hash
  end

  # (see #eql?)
  def ==(other)
    eql?(other)
  end

  # @!visibility private
  def hash
    [language, script, region].hash
  end

  private

  # list of 2 letter country codes
  VALID_LANGUAGES = ::I18nData.languages.keys.collect(&:downcase).sort
end
