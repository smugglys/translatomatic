module Translatomatic
  module Translation
    class RestorePreservedTextException < StandardError; end

    # Data object describing a text translation
    class Result
      # @return [Translatomatic::String] original string
      attr_reader :original

      # @return [Translatomatic::String] translated string
      attr_accessor :result

      # @return [Symbol] The name of the provider. Can be nil for translations
      #   that have been reconstituted from substrings.
      attr_reader :provider

      # @return [boolean] True if this translation came from the database
      attr_reader :from_database

      def initialize(original, result, provider, options = {})
        raise 'original required' unless original.present?
        raise 'result required' unless result.present?
        @original = string(original)
        @result = string(result)
        @provider = provider
        @from_database = options[:from_database]
      end

      # Restore parts of text that should be preserved in the translation
      # @return [void]
      def restore_preserved_text
        preserve_regex = original.preserve_regex
        return unless preserve_regex

        # find parts to preserve in the original string
        parts1 = original.substrings(preserve_regex)
        # find corresponding parts in the translated string
        parts2 = result.substrings(preserve_regex)

        if parts1.length == parts2.length
          # we can restore text. sort by largest offset first.
          conversions = parts1.zip(parts2).collect.sort_by { |i| -i[0].offset }
          conversions.each do |v1, v2|
            result[v2.offset, v2.length] = v1.value
          end
        else
          raise RestorePreservedTextException
        end
      end

      # @return [String] The translated string
      def to_s
        result.to_s
      end

      def description
        format('%<original>s (%<from_locale>s) -> %<result>s (%<to_locale>s)',
               original: original.to_s, result: result.to_s,
               from_locale: original.locale, to_locale: result.locale)
      end

      private

      def string(string)
        if string.is_a?(Translatomatic::String)
          string
        else
          Translatomatic::String.new(string, Locale.default)
        end
      end
    end
  end
end
