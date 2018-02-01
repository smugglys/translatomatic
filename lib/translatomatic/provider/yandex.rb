module Translatomatic
  module Provider
    # Interface to the Yandex translation API
    # @see https://tech.yandex.com/translate/
    class Yandex < Base
      define_option :yandex_api_key, use_env: true,
                                     desc: t('provider.yandex.api_key')

      # Create a new Yandex provider instance
      def initialize(options = {})
        super(options)
        @api_key = options[:yandex_api_key] || ENV['YANDEX_API_KEY']
        raise t('provider.yandex.key_required') if @api_key.nil?
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

      BASE_URL = 'https://translate.yandex.net/api/v1.5/tr.json'.freeze
      TRANSLATE_URL = (BASE_URL + '/translate').freeze
      LANGUAGES_URL = (BASE_URL + '/getLangs').freeze
      LIMIT = [nil, 10_000].freeze # strings, characters per request

      def perform_translate(strings, from, to)
        batcher(strings, max_count: LIMIT[0], max_length: LIMIT[1])
          .each_batch do |texts|
          fetch_translations(texts, from, to)
        end
      end

      def fetch_translations(strings, from, to)
        body = request_body(strings, from, to)
        response = http_client.post(TRANSLATE_URL, body)
        log.debug("#{name} response: #{response.body}")
        data = JSON.parse(response.body)
        result = data['text'] || []
        strings.zip(result).each do |original, translated|
          add_translations(original, translated)
        end
      end

      def request_body(strings, from, to)
        {
          key: @api_key,
          text: strings,
          lang: from.language + '-' + to.language,
          format: 'plain' # 'html'
        }
      end
    end
  end
end
