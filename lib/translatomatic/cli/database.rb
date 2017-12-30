module Translatomatic::CLI
  class Database < Thor
    include Translatomatic::Util

    desc "search string [locale]", t("cli.database.search")
    Util.options(self, Translatomatic::Database)
    # Search database for the given string
    # @param search [String] String to search for
    # @param locale [String] Optional locale, by default search all locales
    # @return [void]
    def search(string, locale = nil)
      Translatomatic::Database.new(options)
      texts = Translatomatic::Model::Text.where('value LIKE ?', "%#{string}%")
      if locale
        db_locale = Translatomatic::Model::Locale.from_tag(locale)
        texts = texts.where(locale: db_locale)
      end
      texts.find_each do |text|
        puts "(%s) %s" % [text.locale, text.value]
        text.translations.each do |translation|
          puts "  -> (%s) %s" % [translation.locale, translation.value]
        end
      end
    end

  end
end
