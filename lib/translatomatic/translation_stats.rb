# Translation statistics
module Translatomatic
  class TranslationStats
    include Translatomatic::Util

    # @return [Array<Translatomatic::Translation>]
    #   A list of all translations
    attr_reader :translations

    # @return [Number] The number of translations that came from the database.
    attr_reader :from_db

    # @return [Number] The number of translations that came from the translator.
    attr_reader :from_translator

    # @return [Number] The number of untranslated strings
    attr_reader :untranslated

    private

    def initialize(translations)
      @translations = tlist = translations.values
      @from_db = tlist.count { |i| i.from_database && i.result }
      @from_translator = tlist.count { |i| !i.from_database && i.result }
      @untranslated = tlist.count { |i| i.result.nil? }
    end

    def to_s
      t('file_translator.total_translations', total: @translations.length,
        from_db: @from_db, from_translator: @from_translator,
        untranslated: @untranslated)
      end
    end
  end
