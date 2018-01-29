module Translatomatic
  module Translation
    class Fetcher

      def initialize(options = {})
        ATTRIBUTES.each do |i|
          instance_variable_set("@#{i}", options[i])
        end
      end

      def translations
        collection = Collection.new

        # add all translations from the database to the collection
        if @use_db
          db_translations = find_database_translations(@strings)
          collection.add(db_translations)
        end

        # request translations for all strings that aren't in the database
        untranslated = untranslated(collection)
        if untranslated.present?
          provider_translations = find_provider_translations(untranslated)
          save_database_translations(provider_translations)
          collection.add(provider_translations)
        end

        collection
      end

      private

      include Util

      ATTRIBUTES = %i[provider strings from_locale to_locale use_db].freeze

      # find strings that we do not have translations for
      # @param collection [Collection] Translation collection
      # @return [Array<String>] Untranslated strings
      def untranslated(collection)
        @strings.select { |i| !collection.translated?(i, @provider.name) }
      end

      # @return [Array<Result>] translations from the database
      def find_database_translations(strings)
        from = db_locale(@from_locale)
        to = db_locale(@to_locale)

        db_texts = Translatomatic::Model::Text.where(
          locale: to,
          provider: @provider.name,
          from_texts_texts: {
            locale_id: from,
            # convert untranslated set to strings
            value: strings.collect(&:to_s)
          }
        ).joins(:from_text)

        texts_to_translations(db_texts, strings)
      end

      # @return [Array<Result>] translations from provider
      def find_provider_translations(strings)
        translations = @provider.translate(
          strings, @from_locale, @to_locale
        )
        # check for valid response from provider and restore variables
        translations.select do |tr|
          raise t('provider.invalid_response') unless tr.is_a?(Result)
          restore_variables(tr)
        end
      end

      def restore_variables(tr)
        tr.restore_preserved_text
        true
      rescue RestorePreservedTextException
        log.debug("unable to restore variables: #{tr}")
        false
      end

      # use the original string from strings in the translation rather than
      # db_text.from_text.value, as the original string has required
      # information such as offset and context.
      def texts_to_translations(db_texts, strings)
        db_text_map = hashify(db_texts, proc { |i| i.from_text.value })
        strings.collect do |string|
          next unless db_text = db_text_map[string.to_s]
          provider = db_text.provider
          Result.new(string, db_text.value, provider, from_database: true)
        end.compact
      end

      def save_database_translations(translations)
        return unless @use_db
        ActiveRecord::Base.transaction do
          from = db_locale(@from_locale)
          to = db_locale(@to_locale)
          translations.each do |tr|
            next if tr.result.nil? # skip invalid translations
            save_database_translation(from, to, tr)
          end
        end
      end

      def save_database_translation(from_locale, to_locale, translation)
        original_text = Translatomatic::Model::Text.find_or_create_by!(
          locale: from_locale,
          value: translation.original.to_s
        )

        text = Translatomatic::Model::Text.find_or_create_by!(
          locale: to_locale,
          value: translation.result.to_s,
          from_text: original_text,
          provider: @provider.name
        )
        text
      end

      def db_locale(locale)
        Translatomatic::Model::Locale.from_tag(locale)
      end
    end
  end
end
