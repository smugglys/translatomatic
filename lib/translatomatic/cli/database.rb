module Translatomatic::CLI
  # Database functions for the command line interface
  class Database < Base
    desc 'search string [locale]', t('cli.database.search')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::Database)
    # Search database for the given string
    # @param string [String] String to search for
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
        puts format('(%s) %s', text.locale, text.value)
        text.translations.each do |translation|
          puts format('  -> (%s) %s', translation.locale, translation.value)
        end
        puts
      end
    end

    desc 'drop', t('cli.database.drop')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::Database)
    def drop
      Translatomatic::Database.new(options).drop
    end
  end
end
