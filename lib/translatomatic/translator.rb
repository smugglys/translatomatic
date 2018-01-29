module Translatomatic
  # Translates strings from one language to another
  class Translator
    attr_reader :stats

    attr_reader :new_translations

    def initialize(options = {})
      @listener = options[:listener]
      @providers = resolve_providers(options)
      raise t('translator.provider_required') if @providers.empty?
      @providers.each { |i| i.listener = @listener } if @listener

      # use database by default if we're connected to a database
      @use_db = !options[:no_database] && ActiveRecord::Base.connected?
      log.debug(t('translator.database_disabled')) unless @use_db

      @new_translations = Translation::Collection.new
      @stats = Translatomatic::Translation::Stats.new
    end

    # Translate strings to a target locale
    # @param strings [Array<Translatomatic::String>] Strings to translate
    # @param to_locale [Locale] Target locale
    # @return [Array<Translatomatic::Translation>] Translations
    def translate(strings, to_locale)
      string_collection = StringCollection.new(strings)

      # do nothing if target language is the same as source language
      # return file if file.locale.language == to_locale.language

      # for each provider
      #   get translations for all strings from the database
      #   for strings that are untranslated, call the provider
      # return translations

      update_listener_total(string_collection)
      translation_collection = Translation::Collection.new
      string_collection.each_locale do |from_locale, list|
        next if list.blank?
        @providers.each do |provider|
          finder = Translation::Fetcher.new(
            provider: provider, strings: list, use_db: @use_db,
            from_locale: from_locale, to_locale: to_locale
          )
          translation_collection += finder.translations
        end
      end

      @new_translations += translation_collection.from_providers
      combine_substrings(translation_collection, string_collection.originals)
      translation_collection
    end

    private

    include Util

    def update_listener_total(string_collection)
      return unless @listener
      @listener.total = string_collection.count * @providers.length
    end

    # Combine translations of substrings of the original strings
    # @param translation_collection [Translatomatic::Translation::Collection]
    #   Translation collection
    # @param parents [Array<String>] The list of original strings
    # @return [void]
    def combine_substrings(translation_collection, parents)
      parents.each do |parent|
        # get a list of substring translations for this parent string
        list = translation_collection.sentences(parent)
        # skip if we have no substrings for this string
        next if list.blank?
        list = list.sort_by { |tr| -tr.original.offset }

        translated_parent = string(parent.value.dup, @to_locale)
        list.each do |tr|
          original = tr.original
          translated = tr.result
          translated_parent[original.offset, original.length] = translated.to_s
        end

        # add the translation that results from combining the translated
        # substrings to the translation collection
        new_translation = translation(parent, translated_parent)
        translation_collection.add(new_translation)
      end
    end

    def translation(original, result, provider = nil, options = {})
      Translatomatic::Translation::Result.new(
        original, result, provider, options
      )
    end

    # update result with translations from the provider.
    def translate_properties_with_provider(result)
      untranslated = result.untranslated.to_a.select { |i| translatable?(i) }
      translated = []
      if !untranslated.empty? && !@dry_run
        provider = @current_provider
        log.debug("translating: #{untranslated.length} strings with #{provider.name}")
        translations = provider.translate(
          untranslated, result.from_locale, result.to_locale
        )
        # log.debug("results: #{translations}")

        # check for valid response from provider
        translations.each do |t|
          raise t('provider.invalid_response') unless t.is_a?(Translation)
          restore_variables(result, t)
        end

        result.add_translations(translations)
        save_database_translations(result, translations)
      end
      translated
    end

    # update result with translations from the database.
    def translate_properties_with_db(_strings)
      return if database_disabled?
      translations = []
      untranslated = hashify(result.untranslated)
      db_texts = find_database_translations(result, result.untranslated.to_a)
      db_texts.each do |db_text|
        from_text = db_text.from_text.value
        original = untranslated[from_text]
        next unless original
        translation = translation(original, db_text.value, true)
        restore_variables(result, translation)
        translations << translation
      end

      result.add_translations(translations)
      log.debug("found #{translations.length} translations in database")
      @listener.update_progress(translations.length) if @listener
    end

    def resolve_providers(options)
      Translatomatic::Provider.resolve(options[:provider], options)
    end
  end
end
