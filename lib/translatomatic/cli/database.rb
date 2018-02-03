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

        # find all matching texts
        texts = db.text.where('value LIKE ?', "%#{string}%")
        if locale
          db_locale = db.locale.from_tag(locale)
          texts = texts.where(locale: db_locale)
        end

        # get all the associated original texts
        original_texts = texts.where(from_text_id: nil)
        from_ids = texts.where('from_text_id IS NOT NULL')
                        .select(:from_text_id).collect(&:from_text_id)
        original2 = db.text.where('id IN (?)', from_ids)
        original_texts += original2

        original_texts.uniq.each do |text|
          value = highlight(text.value, string)
          puts
          puts format('id:%<id>d (%<locale>s) %<value>s',
                      id: text.id, locale: text.locale, value: value)
          rows = []
          text.translations.each do |t|
            rows << ['  -> ', t.provider, "(#{t.locale})",
                     highlight(t.value, string)]
          end
          print_table(rows)
        end
      end

      desc 'delete text_id', t('cli.database.delete_text')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::Database)
      # Delete a text and its translations from the database
      # @param text_id [Number] id of text to delete
      # @return [void]
      def delete(text_id)
        db = Translatomatic::Database.new(options)
        text = db.text.find(text_id)
        raise t('cli.database.text_not_found', id: text_id) unless text
        text.destroy
      end

      desc 'drop', t('cli.database.drop')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::Database)
      # Drop the database
      def drop
        Translatomatic::Database.new(options).drop
      end

      desc 'info', t('cli.database.info')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::Database)
      # Show information about the database
      def info
        db = Translatomatic::Database.new(options)
        puts t('cli.database.text_count', count: db.text.count)
        texts_by_locale = db.text.group(:locale).count
        texts_by_locale.each do |locale, count|
          puts format('  (%<locale>s) %<count>d',
                      locale: locale.to_s, count: count)
        end
      end

      private

      def highlight(text, highlighted)
        text.gsub(highlighted) { |i| rainbow.wrap(i).bright.inverse }
      end
    end
  end
end
