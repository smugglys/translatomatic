module Translatomatic
  # Translates strings from one language to another
  class Translator
    attr_reader :stats

    def initialize(options = {})
      @listener = options[:listener]
      @providers = resolve_providers(options)
      raise t('translator.provider_required') if @providers.empty?
      @providers.each { |i| i.listener = @listener } if @listener

      # use database by default if we're connected to a database
      @use_db = !options[:no_database] && ActiveRecord::Base.connected?
      log.debug(t('translator.database_disabled')) unless @use_db

      @stats = Translatomatic::Translation::Stats.new
    end

    # Translate texts to a target locale
    # @param texts [Array<Translatomatic::Text>] Texts to translate
    # @param to_locales [Array<Locale>] Target locale(s)
    # @return [Array<Translatomatic::Translation>] Translations
    def translate(texts, to_locales)
      text_collection = TextCollection.new(texts)
      to_locales = [to_locales] unless to_locales.is_a?(Array)

      # for each provider
      #   get translations for all texts from the database
      #   for texts that are untranslated, call the provider
      # return translations

      log.debug("translating #{text_collection.count} texts")
      update_listener_total(text_collection, to_locales)
      translation_collection = Translation::Collection.new
      text_collection.each_locale do |from_locale, list|
        next if list.blank?
        @providers.each do |provider|
          to_locales.each do |to_locale|
            fetcher = Translation::Fetcher.new(
              provider: provider, texts: list, use_db: @use_db,
              from_locale: from_locale, to_locale: to_locale
            )
            translations = fetcher.translations
            translation_collection += translations
            update_stats(translations)
          end
        end
      end

      combine_substrings(translation_collection, text_collection, to_locales)
      translation_collection
    end

    private

    include Util
    include DefineOptions

    define_option :no_database, type: :boolean, default: false,
                                desc: t('translator.no_database')

    def update_listener_total(text_collection, to_locales)
      return unless @listener
      @listener.total = text_collection.count * @providers.length *
        to_locales.length
    end

    # Combine translations of substrings of the original strings
    # @param tr_collection [Translatomatic::Translation::Collection]
    #   Translation collection
    # @return [void]
    def combine_substrings(tr_collection, text_collection, to_locales)
      to_locales.each do |to_locale|
        text_collection.originals.each do |parent|
          combine_parent_substrings(tr_collection, parent, to_locale)
        end
      end
    end

    def combine_parent_substrings(tr_collection, parent, to_locale)
      # get a list of substring translations for this parent string
      list = tr_collection.sentences(parent, to_locale)
      # skip if we have no substrings for this string
      return if list.blank?
      list = list.sort_by { |tr| -tr.original.offset }

      translated_parent = build_text(parent.value.dup, to_locale)
      list.each do |tr|
        original = tr.original
        translated = tr.result
        translated_parent[original.offset, original.length] = translated.to_s
      end

      # add the translation that results from combining the translated
      # substrings to the translation collection
      new_translation = translation(parent, translated_parent)
      tr_collection.add(new_translation)
    end

    def translation(original, result, provider = nil, options = {})
      Translatomatic::Translation::Result.new(
        original, result, provider, options
      )
    end

    def resolve_providers(options)
      Translatomatic::Provider.resolve(options[:provider], options)
    end

    def update_stats(tr_collection)
      stats = Translatomatic::Translation::Stats.new(
        tr_collection.translations
      )
      @stats += stats
    end
  end
end
