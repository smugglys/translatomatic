module Translatomatic
  module Translator

    # Interface to the Yandex translation API
    # @see https://tech.yandex.com/translate/
    class Yandex < Base

      define_options({
        name: :yandex_api_key, desc: t("translator.yandex_api_key"), use_env: true
        })

      # Create a new Yandex translator instance
      def initialize(options = {})
        super(options)
        @api_key = options[:yandex_api_key] || ENV["YANDEX_API_KEY"]
        raise t("translator.yandex_key_required") if @api_key.nil?
      end

      # (see Translatomatic::Translator::Base#languages)
      def languages
        @languages ||= begin
          request = Translatomatic::HTTPRequest.new(LANGUAGES_URL)
          response = request.post(key: @api_key, ui: "en")
          data = JSON.parse(response.body) || {}
          langs = data["langs"] || {}
          langs.keys.flatten.uniq
        end
      end

      private

      TRANSLATE_URL = 'https://translate.yandex.net/api/v1.5/tr.json/translate'
      LANGUAGES_URL = 'https://translate.yandex.net/api/v1.5/tr.json/getLangs'

      def perform_translate(strings, from, to)
        attempt_with_retries(3) do
          fetch_translations(strings, from, to)
        end
      end

      def fetch_translations(strings, from, to)
        request = Translatomatic::HTTPRequest.new(TRANSLATE_URL)
        body = {
          key: @api_key,
          text: strings,
          lang: from.language + "-" + to.language,
          format: "plain"
        }
        response = request.post(body)
        data = JSON.parse(response.body)
        data['text']
      end

    end # class
  end   # module
end
