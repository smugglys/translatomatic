module Translatomatic
  module TMX
    # A TMX Translation Unit.
    # A translation unit contains a list of strings, and is part of a TMX
    # document.
    # @see Translatomatic::TMX::Document
    class TranslationUnit
      # @return [Array<Translatomatic::String>] Strings in this translation unit
      attr_reader :strings

      # @param strings [Array<Translatomatic::String>] List of strings
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
end
