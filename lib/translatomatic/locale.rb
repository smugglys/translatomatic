class Translatomatic::Locale

  attr_reader :language
  attr_reader :script
  attr_reader :region

  def self.parse(tag, validate = true)
    locale = new(tag)
    validate && !locale.valid? ? nil : locale
  end

  def self.default
    DEFAULT_LOCALE
  end

  def initialize(tag)
    @impl = I18n::Locale::Tag::Rfc4646.tag(tag)
    if @impl
      @language = @impl.language
      @script = @impl.script
      @region = @impl.region
    end
  end

  def language
    @impl ? @impl.language : nil
  end

  def valid?
    # test if lang is a valid ISO 639-1 language
    @impl && VALID_LANGUAGES.include?(@impl.language) ? true : false
  end

  def to_s
    @impl ? @impl.to_s : ""
  end

  def eql?(other)
    other.kind_of?(Translatomatic::Locale) && other.hash == hash
  end

  def ==(other)
    eql?(other)
  end

  def hash
    @impl ? @impl.members.hash : super
  end

  private

  # list of 2 letter country codes
  VALID_LANGUAGES = ::I18nData.languages.keys.collect { |i| i.downcase }.sort
  DEFAULT_LOCALE = parse(I18n.default_locale)

end
