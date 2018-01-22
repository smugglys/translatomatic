module Translatomatic
  module Translator
    # Interface to the Yandex translation API
    # @see https://tech.yandex.com/translate/
    class Yandex < Base
      define_option :yandex_api_key, use_env: true,
                                     desc: t('translator.yandex.api_key')

      # Create a new Yandex translator instance
      def initialize(options = {})
        super(options)
        @api_key = options[:yandex_api_key] || ENV['YANDEX_API_KEY']
        raise t('translator.yandex.key_required') if @api_key.nil?
      end

      # (see Base#languages)
      def languages
        @languages ||= begin
          response = http_client.post(LANGUAGES_URL, key: @api_key, ui: 'en')
          data = JSON.parse(response.body) || {}
          langs = data['langs'] || {}
          langs.keys.flatten.uniq
        end
      end

      private

      TRANSLATE_URL = 'https://translate.yandex.net/api/v1.5/tr.json/translate'.freeze
      LANGUAGES_URL = 'https://translate.yandex.net/api/v1.5/tr.json/getLangs'.freeze

      def perform_translate(strings, from, to)
        attempt_with_retries(3) do
          fetch_translations(strings, from, to)
        end
      end

      def fetch_translations(strings, from, to)
        body = {
          key: @api_key,
          text: strings,
          lang: from.language + '-' + to.language,
          format: 'plain'
        }
        response = http_client.post(TRANSLATE_URL, body)
        log.debug("#{name} response: #{response.body}")
        data = JSON.parse(response.body)
        data['text']
      end
    end
  end
end
