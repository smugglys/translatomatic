require 'set'

module Translatomatic
  module Translation
    # Stores results of translations.
    # For each original text, there may be zero or more translations from
    # one or more providers.
    class Collection
      # Create a translation collection
      def initialize
        # by_provider[provider] = [Result, ...]
        @by_provider = {}
        # by_original[text] = [Result, ...]
        @by_original = {}
      end

      # @param string [String,Text] Original string
      # @return [Array<Result>] All translations for the given string
      def [](string)
        @by_original[string.to_s]
      end

      def empty?
        @by_original.empty?
      end

      # @param string [String,Text] Original string
      # @param locale [Locale] Target locale
      # @return [Result] The best translation for the given string
      def get(string, locale)
        locale = build_locale(locale)
        list = @by_original[string.to_s] || []
        list = sort_by_best_match(list)
        if string.is_a?(Translatomatic::Text) && string.context
          # string has a context
          list = sort_by_context_match(list, string.context, locale)
        end
        list.find { |i| i.result.locale == locale }
      end

      # Add a list of translations to the collection
      # @param translations [Array<Result>] Translation results
      # @return [void]
      def add(translations)
        translations = [translations] unless translations.is_a?(Array)
        translations.each do |tr|
          next if tr.result.nil?
          add_to_list(@by_provider, tr.provider, tr)
          add_to_list(@by_original, tr.original, tr)
        end
      end

      # @return [Number] The number of translations
      def count
        translations.length
      end

      # Get translations from this collection. If provider is specified,
      # returns only translations from the given provider, otherwise all
      # translations are returned.
      # @param provider [String] Optional name of a provider.
      # @return [Array<Result>] Translation results
      def translations(provider = nil)
        if provider.nil?
          @by_provider.values.flatten
        else
          @by_provider[provider.to_s] || []
        end
      end

      # Get a list of the best sentence translations for the given
      # parent string.
      # @param parent [Text] Parent text
      # @param locale [Locale] Target locale
      # @return [Array<Result>] Substring translation results
      def sentences(parent, locale)
        parent.sentences.collect do |sentence|
          # get translation for sentence
          tr = get(sentence, locale)
          # create a new translation with the sentence as the original
          # string, so that we can rely on the offset value.
          Result.new(
            sentence, tr.result, tr.provider, from_database: tr.from_database
          ) if tr
        end.compact
      end

      # Return a new collection with only the translations that came from
      # providers (not from the database).
      # @return [Collection] The collection result
      def from_providers
        result = self.class.new
        provider_translations = translations.reject(&:from_database)
        result.add(provider_translations)
        result
      end

      # @return [Array<Result>] Best translations for each string
      # @param locale [Locale] Target locale
      def best_translations(locale)
        @by_original.keys.collect { |i| get(i, locale) }
      end

      # @return [Array<String>] A list of providers that translations were
      #   sourced from.
      def providers
        @by_provider.keys
      end

      # Combine this collection with another
      # @param other [Collection] Another collection
      # @return [Collection] The collection result
      def +(other)
        result = self.class.new
        @by_provider.values.each { |i| result.add(i) }
        other.translations.each { |i| result.add(i) }
        result
      end

      # @param string [String,Text] Original string
      # @param provider [String] Provider name
      # @return [boolean] True if there is a translation for the given string.
      def translated?(string, provider)
        list = @by_provider[provider.to_s] || []
        list.any? { |tr| tr.original.to_s == string.to_s }
      end

      # @return [String] String description of all translations
      def description
        translations.collect(&:description).join("\n")
      end

      private

      include Translatomatic::Util

      # sort the list of translations by comparing to the translation for
      # the string context.
      # for example:
      #   context is 'go right' with a translation of 'Geh rechts'.
      #   translation of 'right' is 'rechts', and 'richtig'.
      #   translation 'rechts' will be ordered first, as 'rechts' is in
      #     the translated context string (and is longer than 'recht').
      def sort_by_context_match(list, context, locale)
        return list if list.blank?
        context_tr = get(Text[context, list[0].original.locale], locale)
        unless context_tr
          log.error("no translation for context string '#{context}'")
          return list
        end
        context_result = context_tr.result.downcase
        log.debug("context translation: #{context_tr.description}")
        # put translations that include the context string first.
        # put longer translations first.
        list.sort_by do |tr|
          tr_result = tr.result.downcase
          context_result.include?(tr_result) ? -tr_result.length : 1
        end
      end

      # sort the list of translations by finding the most common
      # translation. if there is an equal number of different translations
      # use the first most common translation (first provider).
      def sort_by_best_match(list)
        by_count = {}
        list.each do |tr|
          key = tr.result.downcase
          by_count[key] = (by_count[key] || 0) + 1
        end

        # not using sort_by to maintain original sort order
        # unless count is different.
        list.sort do |tr1, tr2|
          by_count[tr1.result.downcase] <=> by_count[tr2.result.downcase]
        end
      end

      def add_to_list(hash, key, value)
        list = hash[key.to_s] ||= []
        list << value
      end
    end
  end
end
