module Translatomatic
  module CLI
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
        db = Translatomatic::Database.new(options)
        texts = db.text.where('value LIKE ?', "%#{string}%")
        if locale
          db_locale = db.locale.from_tag(locale)
          texts = texts.where(locale: db_locale)
        end
        template1 = '(%<locale>s) %<value>s'
        template2 = '  -> ' + template1
        texts.find_each do |text|
          puts format(template1, locale: text.locale, value: text.value)
          text.translations.each do |t|
            puts format(template2, locale: t.locale, value: t.value)
          end
          puts
        end
      end

      desc 'drop', t('cli.database.drop')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::Database)
      # Drop the database
      def drop
        Translatomatic::Database.new(options).drop
      end
    end
  end
end
