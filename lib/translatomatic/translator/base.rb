require 'bing_translator'

module Translatomatic
  module Translator
    # @abstract
    class Base

      class << self
        attr_reader :options
        private
        include Translatomatic::DefineOptions
      end

      # @private
      attr_accessor :listener

      def initialize(options = {})
        @listener = options[:listener]
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
        translated = perform_translate(strings, from, to)
        update_translated(translated) unless @updated_listener
        translated
      end

      private

      include Translatomatic::Util

      # fetch translations for the given strings, one at a time, by
      # opening a http connection to the given url and calling
      # fetch_translation() on each string.
      # (subclass must implement fetch_translation if this method is used)
      def perform_fetch_translations(url, strings, from, to)
        translated = []
        request = Translatomatic::HTTPRequest.new(url)
        request.start do |http|
          strings.each do |string|
            result = fetch_translation(request, string, from, to)
            translated << result
            update_translated(result)
          end
        end
        translated
      end

      def fetch_translation(request, strings, from, to)
        raise "subclass must implement fetch_translation"
      end

      def update_translated(texts)
        texts = [texts] unless texts.kind_of?(Array)
        @updated_listener = true
        @listener.translated_texts(texts) if @listener
      end

      def perform_translate(strings, from, to)
        raise "subclass must implement perform_translate"
      end

    end
  end
end
