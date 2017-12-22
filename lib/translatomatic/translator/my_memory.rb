require 'bing_translator'

module Translatomatic
  module Translator

    class MyMemory < Base

      URL = 'https://api.mymemory.translated.net/get'

      define_options(
        { name: :mymemory_api_key, desc: "MyMemory API key", use_env: true },
        { name: :mymemory_email, desc: "Email address", use_env: true }
        )

      def initialize(options = {})
        @key = options[:mymemory_api_key] || ENV["MYMEMORY_API_KEY"]
        @email = options[:mymemory_email] || ENV["MYMEMORY_EMAIL"]
      end

      # TODO: implement language list
      #def languages
      #end

      def perform_translate(strings, from, to)
        translated = []
        uri = URI.parse(URL)

        http_options = { use_ssl: uri.scheme == "https" }
        Net::HTTP.start(uri.host, uri.port, http_options) do |http|
          strings.each do |string|
            query = {
              langpair: from.to_s + "|" + to.to_s,
              q: string
            }
            query.merge!(de: @email) if @email
            query.merge!(key: @key) if @key
            uri.query = URI.encode_www_form(query)

            req = Net::HTTP::Get.new(uri)
            response = http.request(req)
            raise response.body unless response.kind_of? Net::HTTPSuccess
            data = JSON.parse(response.body)
            translated << data['responseData']['translatedText']
          end
          translated
        end
      end

    end
  end
end
