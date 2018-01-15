require 'i18n'

module Translatomatic
  class I18n
    class << self

      def t(key, options = {})
        tkey = "translatomatic.#{key}"
        raise "missing translation: #{tkey}" unless ::I18n.exists?(tkey)

        ::I18n.t(tkey, options.merge(locale: t_locale(options)))
      end

      private

      FALLBACK_LOCALE = "en"

      def init_i18n(root_path)
        locale_path = File.join(root_path, 'config', 'locales')
        ::I18n.load_path += Dir[File.join(locale_path, '**', '*.yml')]
      end

      def t_locale(options)
        locale = options[:locale] || Locale.default.to_s
        locale = FALLBACK_LOCALE unless ::I18n.locale_available?(locale)
        locale
      end
    end

    begin
      init_i18n(File.join(__dir__, "..", ".."))
    end
  end
end
