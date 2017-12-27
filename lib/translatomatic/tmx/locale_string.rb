module Translatomatic::TMX
  class LocaleString

    # @return [String] The string
    attr_reader :value

    # @return [Translatomatic::Locale] The string's locale
    attr_reader :locale

    def initialize(value, locale)
      @locale = locale
      @value = value
    end

    def to_s
      @value
    end
  end
end
