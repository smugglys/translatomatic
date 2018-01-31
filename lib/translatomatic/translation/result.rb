module Translatomatic
  module Translation
    # Exception raised when preserved text could not be restored in a
    # translated text.
    class RestorePreservedTextException < StandardError; end

    # Data object describing a text translation
    class Result
      # @return [Translatomatic::Text] original string
      attr_reader :original

      # @return [Translatomatic::Text] translated string
      attr_accessor :result

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

      # Restore parts of text that should be preserved in the translation
      # @return [void]
      def restore_preserved_text
        preserve_regex = original.preserve_regex
        return unless preserve_regex

        # find parts to preserve in the original string
        list1 = original.substrings(preserve_regex)
        # find corresponding parts in the translated string
        list2 = result.substrings(preserve_regex)

        raise RestorePreservedTextException unless list1.length == list2.length

        # we can restore text. sort by largest offset first.
        conversions = list1.zip(list2).collect.sort_by { |i| -i[0].offset }
        conversions.each do |v1, v2|
          result[v2.offset, v2.length] = v1.value
        end
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
