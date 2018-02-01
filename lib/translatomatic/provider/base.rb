module Translatomatic
  module Provider
    # Base class for interfaces to translation APIs
    # @abstract
    class Base
      include Translatomatic::DefineOptions

      # Listener for translation events
      attr_accessor :listener

      # @return [boolean] True if a string can have alternative translations
      def self.supports_alternative_translations?
        false
      end

      # @return [boolean] true if this provider supports html5
      #   <span translate="no"></span> tags.
      def self.supports_no_translate_html?
        false
      end

      def initialize(options = {})
        @listener = options[:listener]
      end

      # @return [String] The name of this provider.
      def name
        self.class.name.demodulize
      end

      # @return [String] The name of this provider
      def to_s
        name
      end

      # @return [Array<String>] A list of languages
      #   supported by this provider.
      def languages
        []
      end

      # Translate strings from one locale to another
      # @param strings [Array<String,Text>] A list of text/strings to translate.
      # @param from [String, Translatomatic::Locale] The locale of the
      #   given strings.
      # @param to [String, Translatomatic::Locale] The locale to translate to.
      # @return [Array<Translatomatic::Translation::Result>] Translations
      def translate(strings, from, to)
        @updated_listener = false
        @translations = []
        @from = from
        @to = to
        strings = [strings] unless strings.is_a?(Array)
        from = build_locale(from)
        to = build_locale(to)
        if from.language == to.language
          strings.each { |i| add_translations(i, i) }
        else
          perform_translate(strings, from, to)
        end
        @translations
      end

      private

      include Translatomatic::Util

      TRANSLATION_RETRIES = 3

      # all subclasses must implement this
      def perform_translate(_strings, _from, _to)
        raise 'subclass must implement perform_translate'
      end

      # subclasses that call perform_fetch_translations must implement this
      def fetch_translations(_string, _from, _to)
        raise 'subclass must implement fetch_translations'
      end

      def http_client(*args)
        @http_client ||= Translatomatic::HTTP::Client.new(*args)
      end

      # Fetch translations for the given strings, one at a time, by
      # opening a http connection to the given url and calling
      # fetch_translation() on each string. Error handling and recovery
      # is performed by this method.
      # (subclass must implement fetch_translation if this method is used)
      def perform_fetch_translations(url, strings, from, to)
        untranslated = strings.dup

        http_client.start(url) do |_http|
          until untranslated.empty?
            # get next string to translate
            string = untranslated[0]
            # fetch translation
            fetch_translations(string, from, to)
            untranslated.shift
          end
        end
      end

      def add_translations(original, result)
        # successful translation
        result = [result] unless result.is_a?(Array)
        result = convert_to_translations(original, result)
        @listener.update_progress(1) if @listener
        @translations += result
      end

      def convert_to_translations(original, result)
        result.collect { |i| translation(original, i) }.compact
      end

      def translation(original, translated)
        return nil if translated.blank?
        string1 = Translatomatic::Text[original, @from]
        string2 = Translatomatic::Text[translated, @to]
        Translatomatic::Translation::Result.new(string1, string2, name)
      end

      def batcher(strings, max_count:, max_length:)
        StringBatcher.new(strings, max_count: max_count, max_length: max_length)
      end
    end
  end
end
