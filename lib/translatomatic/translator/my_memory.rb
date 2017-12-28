require 'bing_translator'

module Translatomatic
  module Translator

    class MyMemory < Base

      define_options(
        { name: :mymemory_api_key, desc: "MyMemory API key", use_env: true },
        { name: :mymemory_email, desc: "Email address", use_env: true }
        )

      # Create a new MyMemory translator instance
      def initialize(options = {})
        super(options)
        @key = options[:mymemory_api_key] || ENV["MYMEMORY_API_KEY"]
        @email = options[:mymemory_email] || ENV["MYMEMORY_EMAIL"]
        @query_options = {}
        @query_options.merge!(de: @email) if @email
        @query_options.merge!(key: @key) if @key
      end

      # TODO: implement language list
      # (see Translatomatic::Translator::Base#languages)
      #def languages
      #end

      # Upload a set of translations to MyMemory
      # @param [Translatomatic::TMX::Document] TMX document
      def upload(tmx)
        request = Translatomatic::HTTPRequest.new(UPLOAD_URL)
        request.start do |http|
          body = [
            request.file(key: :tmx, filename: "import.tmx",
              content: tmx.to_xml, mime_type: "application/xml"
            ),
            request.param(key: :private, value: 0)
          ]
          response = request.post(body, multipart: true)
          log.debug("share response: #{response.body}")
        end
      end

      private

      GET_URL = 'https://api.mymemory.translated.net/get'
      UPLOAD_URL = 'https://api.mymemory.translated.net/tmx/import'

      def perform_translate(strings, from, to)
        perform_fetch_translations(GET_URL, strings, from, to)
      end

      def fetch_translation(request, string, from, to)
        response = request.get({
            langpair: from.to_s + "|" + to.to_s,
            q: string
          }.merge(@query_options)
        )
        data = JSON.parse(response.body)
        data['responseData']['translatedText']
      end
    end
  end
end
