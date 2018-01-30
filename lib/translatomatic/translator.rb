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

    # Translate strings to a target locale
    # @param strings [Array<Translatomatic::String>] Strings to translate
    # @param to_locales [Array<Locale>] Target locale(s)
    # @return [Array<Translatomatic::Translation>] Translations
    def translate(strings, to_locales)
      string_collection = StringCollection.new(strings)
      to_locales = [to_locales] unless to_locales.is_a?(Array)

      # for each provider
      #   get translations for all strings from the database
      #   for strings that are untranslated, call the provider
      # return translations

      log.debug("translating #{string_collection.count} strings")
      update_listener_total(string_collection, to_locales)
      translation_collection = Translation::Collection.new
      string_collection.each_locale do |from_locale, list|
        next if list.blank?
        @providers.each do |provider|
          to_locales.each do |to_locale|
            fetcher = Translation::Fetcher.new(
              provider: provider, strings: list, use_db: @use_db,
              from_locale: from_locale, to_locale: to_locale
            )
            translation_collection += fetcher.translations
          end
        end
      end

      combine_substrings(translation_collection, string_collection, to_locales)
      translation_collection
    end

    private

    include Util
    include DefineOptions

    define_option :no_database, type: :boolean, default: false,
                                desc: t('translator.no_database')

    def update_listener_total(string_collection, to_locales)
      return unless @listener
      @listener.total = string_collection.count * @providers.length *
        to_locales.length
    end

    # Combine translations of substrings of the original strings
    # @param tr_collection [Translatomatic::Translation::Collection]
    #   Translation collection
    # @return [void]
    def combine_substrings(tr_collection, string_collection, to_locales)
      to_locales.each do |to_locale|
        string_collection.originals.each do |parent|
          combine_parent_substrings(tr_collection, parent, to_locale)
        end
      end
    end

    def combine_parent_substrings(translation_collection, parent, to_locale)
      # get a list of substring translations for this parent string
      list = translation_collection.sentences(parent, to_locale)
      # skip if we have no substrings for this string
      return if list.blank?
      list = list.sort_by { |tr| -tr.original.offset }

      translated_parent = string(parent.value.dup, to_locale)
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

    def translation(original, result, provider = nil, options = {})
      Translatomatic::Translation::Result.new(
        original, result, provider, options
      )
    end

    def resolve_providers(options)
      Translatomatic::Provider.resolve(options[:provider], options)
    end
  end
end
