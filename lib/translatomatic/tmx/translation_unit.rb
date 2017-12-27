module Translatomatic::TMX
  class TranslationUnit

    # @return [Array<LocaleString>] Locale strings in this translation unit
    attr_reader :locale_strings

    # @param [Array<LocaleString>] list of locale strings
    def initialize(locale_strings)
      @locale_strings = locale_strings || []
    end

    # Test translation unit validity.
    # A translation unit must contain at least two locale strings.
    # @return [boolean] true if this translation unit is valid
    def valid?
      @locale_strings.length >= 2
    end
  end
end
