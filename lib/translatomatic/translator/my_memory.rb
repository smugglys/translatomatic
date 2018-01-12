
module Translatomatic
  module Translator
    # Interface to the MyMemory translation API
    # @see https://mymemory.translated.net/doc/
    class MyMemory < Base
      define_options(
        { name: :mymemory_api_key, desc: t('translator.mymemory_api_key'), use_env: true },
        { name: :mymemory_email, desc: t('translator.email_address'), use_env: true }
      )

      # Create a new MyMemory translator instance
      def initialize(options = {})
        super(options)
        @key = options[:mymemory_api_key] || ENV['MYMEMORY_API_KEY']
        @email = options[:mymemory_email] || ENV['MYMEMORY_EMAIL']
        @query_options = {}
        @query_options[:de] = @email if @email
        @query_options.merge!(key: @key) if @key
      end

      # TODO: implement language list
      # (see Translatomatic::Translator::Base#languages)
      # def languages
      # end

      # Upload a set of translations to MyMemory
      # @param tmx [Translatomatic::TMX::Document] TMX document
      # @return [void]
      def upload(tmx)
        request = Translatomatic::HTTPRequest.new(UPLOAD_URL)
        request.start do |_http|
          body = [
            request.file(key: :tmx, filename: 'import.tmx',
                         content: tmx.to_xml, mime_type: 'application/xml'),
            request.param(key: :private, value: 0)
          ]
          response = request.post(body, multipart: true)
          log.debug(t('translator.share_response',
                      response: response.body.inspect))
        end
      end

      private

      GET_URL = 'https://api.mymemory.translated.net/get'.freeze
      UPLOAD_URL = 'https://api.mymemory.translated.net/tmx/import'.freeze

      def perform_translate(strings, from, to)
        perform_fetch_translations(GET_URL, strings, from, to)
      end

      def fetch_translation(request, string, from, to)
        response = request.get({
          langpair: from.to_s + '|' + to.to_s,
          q: string # multiple q strings not supported (tested 20180101)
        }.merge(@query_options))
        data = JSON.parse(response.body)
        data['responseData']['translatedText']
      end
    end
  end
end
