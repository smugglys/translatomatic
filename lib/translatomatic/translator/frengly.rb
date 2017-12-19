require 'net/http'

module Translatomatic
  module Translator

    class Frengly < Base

      URL = 'http://frengly.com/frengly/data/translateREST'

      def initialize(options = {})
        @key = options[:frengly_api_key] || ENV["FRENGLY_API_KEY"] # optional
        @email = options[:frengly_email]
        @password = options[:frengly_password]
      end

      def languages
        ['en','fr','de','es','pt','it','nl','tl','fi','el','iw','pl','ru','sv']
      end

      def perform_translate(strings, from, to)
        translated = []
        uri = URI.parse(URL)

        Net::HTTP.start(uri.host, uri.port) do |http|
          strings.each do |string|
            body = {
              src: from.language,
              dest: to.language,
              text: string,
              email: @email,
              password: @password,
              premiumkey: @key
            }.to_json

            req = Net::HTTP::Post.new(uri)
            req.body = body
            req.content_type = 'application/json'
            response = http.request(req)
            raise response.body if response.code != 200
            translated << response.body
          end
          translated
        end
      end

    end # class
  end   # module
end
