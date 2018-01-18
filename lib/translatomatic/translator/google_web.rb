require 'easy_translate'

module Translatomatic
  module Translator
    # Google translation web interface.
    # supports multiple translations
    # @see https://translate.google.com.au
    class GoogleWeb < Base
      # Create a new GoogleWeb translator instance
      def initialize(options = {})
        super(options)
      end

      # (see Translatomatic::Translator::Base#languages)
      def languages
        EasyTranslate::LANGUAGES.keys
      end

      private

      def perform_translate(strings, from, to)
        perform_fetch_translations(url, strings, from, to)
      end

      def fetch_translation(_request, _strings, _from, _to)
        raise 'subclass must implement fetch_translation'
      end
    end
  end
end
