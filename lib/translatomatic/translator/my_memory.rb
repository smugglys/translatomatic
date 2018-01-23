
module Translatomatic
  module Translator
    # Interface to the MyMemory translation API
    # @see https://mymemory.translated.net/doc/
    class MyMemory < Base
      define_option :mymemory_api_key, use_env: true,
                                       desc: t('translator.mymemory.api_key')
      define_option :mymemory_email, use_env: true,
                                     desc: t('translator.email_address')

      # Create a new MyMemory translator instance
      def initialize(options = {})
        super(options)
        @key = options[:mymemory_api_key] || ENV['MYMEMORY_API_KEY']
        @email = options[:mymemory_email] || ENV['MYMEMORY_EMAIL']
        @query_options = {}
        @query_options[:de] = @email if @email
        @query_options.merge!(key: @key) if @key
      end

      # (see Base#languages)
      def languages
        Locale.language_codes
      end

      # Upload a set of translations to MyMemory
      # @param tmx [Translatomatic::TMX::Document] TMX document
      # @return [void]
      def upload(tmx)
        body = [
          { key: :tmx, filename: 'import.tmx',
            content: tmx.to_xml, mime_type: 'application/xml' },
          { key: :private, value: 0 }
        ]
        response = http_client.post(UPLOAD_URL, body)
        log.debug(t('translator.share_response',
                    response: response.body.inspect))
      end

      private

      GET_URL = 'https://api.mymemory.translated.net/get'.freeze
      UPLOAD_URL = 'https://api.mymemory.translated.net/tmx/import'.freeze
      MAIN_URL = 'https://mymemory.api.net'.freeze

      def perform_translate(strings, from, to)
        perform_fetch_translations(GET_URL, strings, from, to)
      end

      def fetch_translations(string, from, to)
        response = http_client.get(GET_URL, {
          langpair: from.to_s + '|' + to.to_s,
          q: string # multiple q strings not supported (tested 20180101)
        }.merge(@query_options))

        log.debug("#{name} response: #{response.body}")
        data = JSON.parse(response.body)
        # matches = data['matches'] # all translations
        # matches.collect { |i| match_data(i) }
        result = data['responseData']['translatedText']
        add_translations(string, result)
      end

      # https://mymemory.translated.net/doc/features.php
      def match_data(match)
        {
          translation: match['translation'],
          quality: match['quality'],
          usage_count: match['usage-count'],
          match: match['match'], # partial matches, see features.php above
        }
      end
    end
  end
end
