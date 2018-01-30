
module Translatomatic
  module Provider
    # Interface to the Google translation API
    # @see https://cloud.google.com/translate/
    class Google < Base
      define_option :google_api_key,
                    desc: t('provider.google.api_key'), use_env: true
      define_option :google_model, enum: %i[base nmt],
                                   desc: t('provider.google.model'), use_env: true

      # Create a new Google provider instance
      def initialize(options = {})
        super(options)
        @key = options[:google_api_key] || ENV['GOOGLE_API_KEY']
        raise t('provider.google.key_required') if @key.nil?
        @model = options[:google_model]
      end

      # (see Base#languages)
      def languages
        @languages ||= fetch_languages
      end

      private

      BASE_URL = 'https://translation.googleapis.com'.freeze
      TRANSLATE_URL = (BASE_URL + '/language/translate/v2').freeze
      LANGUAGES_URL = (BASE_URL + '/language/translate/v2/languages').freeze
      MAX_TEXTS_PER_REQUEST = 128

      def perform_translate(strings, from, to)
        strings.each_slice(MAX_TEXTS_PER_REQUEST) do |texts|
          perform_translate_texts(texts, from, to)
        end
      end

      def perform_translate_texts(texts, from, to)
        request_body = request_body(texts, from, to)
        response = http_client.post(TRANSLATE_URL, request_body)
        body = JSON.parse(response.body)
        data = body['data'] || {}
        translations = data['translations'] || []
        translations = translations.collect { |i| i['translatedText'] }
        texts.zip(translations).each do |original, translated|
          add_translations(original, translated)
        end
      end

      def request_body(strings, from, to)
        body = {
          q: strings,
          source: from.language,
          target: to.language,
          format: 'text',
          key: @key
        }
        body[:model] = @model if @model
        body
      end

      def fetch_languages
        response = http_client.get(LANGUAGES_URL, key: @key)
        body = JSON.parse(response.body)
        data = body['data'] || {}
        languages = data['languages'] || []
        languages.collect { |i| i['language'] }
      end
    end
  end
end
