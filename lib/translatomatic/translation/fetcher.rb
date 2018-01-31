module Translatomatic
  module Translation
    # Fetches translations from the database and translation providers
    class Fetcher
      def initialize(options = {})
        ATTRIBUTES.each do |i|
          instance_variable_set("@#{i}", options[i])
        end
      end

      # Fetch a list of translations for all texts given in the constructor
      # for all providers.
      # Translations are fetched from the database first, then from providers.
      # @return [Array<Result>] List of translations
      def translations
        collection = Collection.new

        # add all translations from the database to the collection
        collection.add(find_database_translations(@texts)) if @use_db

        # request translations for all texts that aren't in the database
        untranslated = untranslated(collection)
        if untranslated.present?
          provider_translations = find_provider_translations(untranslated)
          save_database_translations(provider_translations)
          collection.add(provider_translations)
        end

        # puts collection.description
        collection
      end

      private

      include Util

      ATTRIBUTES = %i[provider texts from_locale to_locale use_db].freeze

      # find texts that we do not have translations for
      # @param collection [Collection] Translation collection
      # @return [Array<String>] Untranslated texts
      def untranslated(collection)
        @texts.reject { |i| collection.translated?(i, @provider.name) }
      end

      # @return [Array<Result>] translations from the database
      def find_database_translations(texts)
        from = db_locale(@from_locale)
        to = db_locale(@to_locale)

        db_texts = Translatomatic::Model::Text.where(
          locale: to, provider: @provider.name,
          from_texts_texts: {
            locale_id: from,
            # convert untranslated texts to strings
            value: texts.collect(&:to_s)
          }
        ).joins(:from_text)

        texts_to_translations(db_texts, texts)
      end

      # @return [Array<Result>] translations from provider
      def find_provider_translations(texts)
        translations = @provider.translate(
          texts, @from_locale, @to_locale
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

      # use the original text from the translation rather than
      # db_text.from_text.value, as the original string has required
      # information such as offset and context.
      def texts_to_translations(db_texts, texts)
        db_text_map = hashify(db_texts, proc { |i| i.from_text.value })
        texts.collect do |text|
          next unless (db_text = db_text_map[text.to_s])
          provider = db_text.provider
          translation = build_text(db_text.value, @to_locale)
          Result.new(text, translation, provider, from_database: true)
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
          locale: to_locale, value: translation.result.to_s,
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
