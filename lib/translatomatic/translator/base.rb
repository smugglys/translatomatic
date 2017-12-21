require 'bing_translator'

module Translatomatic
  module Translator
    class Base
      include Translatomatic::Util

      class << self
        attr_reader :options
        private
        include Translatomatic::DefineOptions
      end

      # return a list of languages supported by this translator.
      def languages
        []
      end

      def translate(strings, from, to)
        strings = [strings] unless strings.kind_of?(Array)
        from = parse_locale(from) if from.kind_of?(String)
        to = parse_locale(to) if to.kind_of?(String)
        return strings if from.language == to.language
        perform_translate(strings, from, to)
      end

      def perform_translate(strings, from, to)
        raise "subclasses must implement perform_translate"
      end

    end
  end
end
