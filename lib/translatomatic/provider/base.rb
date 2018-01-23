
module Translatomatic
  module Provider
    # Base class for interfaces to translation APIs
    # @abstract
    class Base
      include Translatomatic::DefineOptions

      # Listener for translation events
      attr_accessor :listener

      # @return [boolean] True if a single strings can have multiple results
      def self.supports_multiple_translations?
        false
      end

      def initialize(options = {})
        @listener = options[:listener]
      end

      # @return [String] The name of this provider.
      def name
        self.class.name.demodulize
      end

      # @return [Array<String>] A list of languages
      #   supported by this provider.
      def languages
        []
      end

      # Translate strings from one locale to another
      # @param strings [Array<String>] A list of strings to translate.
      # @param from [String, Translatomatic::Locale] The locale of the
      #   given strings.
      # @param to [String, Translatomatic::Locale] The locale to translate to.
      # @return [Array<Translatomatic::Translation>] Translation results
      def translate(strings, from, to)
        @updated_listener = false
        @translations = []
        @from = from
        @to = to
        strings = [strings] unless strings.is_a?(Array)
        from = locale(from)
        to = locale(to)
        if from.language == to.language
          return strings
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
        @listener.processed_strings(1) if @listener
        @translations += result
      end

      def convert_to_translations(original, result)
        result.collect { |i| translation(original, i) }
      end

      def translation(original, translated)
        string1 = Translatomatic::String[original, @from]
        string2 = Translatomatic::String[translated, @to]
        Translatomatic::Translation.new(string1, string2, provider: name)
      end

      # Attempt to run a block of code up to retries times.
      # Reraises the exception if the block fails retries times.
      # @param retries [Number] The maximum number of times to run
      # @return [Object] the return value of the block
      def attempt_with_retries(retries)
        RetryExecutor.run(max_retries: retries) do
          yield
        end
      end
    end
  end
end
