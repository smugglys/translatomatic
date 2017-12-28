module Translatomatic::TMX
  class TranslationUnit

    # @return [Array<Translatomatic::String>] Strings in this translation unit
    attr_reader :strings

    # @param [Array<Translatomatic::String>] list of strings
    def initialize(strings)
      @strings = strings || []
    end

    # Test translation unit validity.
    # A translation unit must contain at least two strings.
    # @return [boolean] true if this translation unit is valid
    def valid?
      @strings.length >= 2
    end
  end
end
