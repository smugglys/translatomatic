module Translatomatic
  module Translation
    # Data object describing a text translation
    class Result
      # @return [Translatomatic::Text] original string
      attr_reader :original

      # @return [Translatomatic::Text] translated string
      attr_reader :result

      # @return [Symbol] The name of the provider. Can be nil for translations
      #   that have been reconstituted from substrings.
      attr_reader :provider

      # @return [boolean] True if this translation came from the database
      attr_reader :from_database

      def initialize(original, result, provider, options = {})
        raise 'original required' unless original.present?
        raise 'result required' unless result.present?
        @original = build_text(original)
        @result = build_text(result)
        @provider = provider
        @from_database = options[:from_database]
      end

      # @return [String] The translated string
      def to_s
        result.to_s
      end

      # @return [String] A description of this translation
      def description
        format('%<original>s (%<from_locale>s) -> %<result>s (%<to_locale>s)',
               original: original.to_s, result: result.to_s,
               from_locale: original.locale, to_locale: result.locale)
      end

      private

      def build_text(string)
        if string.is_a?(Translatomatic::Text)
          string
        else
          Translatomatic::Text.new(string, Locale.default)
        end
      end
    end
  end
end
