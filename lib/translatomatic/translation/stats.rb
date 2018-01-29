module Translatomatic
  module Translation
    # Translation statistics
    class Stats
      include Translatomatic::Util

      # @return [Array<Translatomatic::Translation>]
      #   A list of all translations
      attr_reader :translations

      # @return [Number] The number of translations that came from the database.
      attr_reader :from_db

      # @return [Number] The number of translations that came from the provider.
      attr_reader :from_provider

      # @return [Number] The number of untranslated strings
      attr_reader :untranslated

      # Combine stats with another object
      # @param other [TranslationStats] Another stats object
      # @return [TranslationStats] The result of adding this to other
      def +(other)
        if other.is_a? TranslationStats
          Stats.new(translations + other.translations)
        else
          raise "expected TranslationStats, got #{other.class}"
        end
      end

      private

      def initialize(translations = [])
        @translations = list = translations
        @from_db = list.count { |i| i.from_database && i.result }
        @from_provider = list.count { |i| !i.from_database && i.result }
        @untranslated = list.count { |i| i.result.nil? }
      end

      def to_s
        key = 'translator.total_translations'
        t(key, total: @translations.length,
               from_db: @from_db, from_provider: @from_provider,
               untranslated: @untranslated)
      end
    end
  end
end