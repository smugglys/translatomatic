require 'bing_translator'

module Translatomatic
  module Translator
    @abstract
    class Base

      class << self
        attr_reader :options
        private
        include Translatomatic::DefineOptions
      end

      # @return [String] The name of this translator.
      def name
        self.class.name.demodulize
      end

      # @return [Array<String>] A list of languages supported by this translator.
      def languages
        []
      end

      # Translate strings from one locale to another
      # @param [Array<String>] strings A list of strings to translate.
      # @param [String, Translatomatic::Locale] from The locale of the given strings.
      # @param [String, Translatomatic::Locale] to The locale to translate to.
      # @return [Array<String>] Translated strings
      def translate(strings, from, to)
        strings = [strings] unless strings.kind_of?(Array)
        from = Translatomatic::Locale.parse(from)
        to = Translatomatic::Locale.parse(to)
        return strings if from.language == to.language
        perform_translate(strings, from, to)
      end

      private

      include Translatomatic::Util

      def perform_translate(strings, from, to)
        raise "subclasses must implement perform_translate"
      end

    end
  end
end
