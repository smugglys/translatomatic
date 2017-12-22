require 'net/http'

module Translatomatic
  module Translator

    class Frengly < Base

      URL = 'http://frengly.com/frengly/data/translateREST'

      define_options({
        name: :frengly_api_key, desc: "Frengly API key", use_env: true
      },
      { name: :frengly_email, desc: "Email address", use_env: true
      },
      { name: :frengly_password, desc: "Password", use_env: true
        })

      def initialize(options = {})
        @key = options[:frengly_api_key] || ENV["FRENGLY_API_KEY"] # optional
        @email = options[:frengly_email]
        @password = options[:frengly_password]
        raise "email address required" unless @email
        raise "password required" unless @password
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

            # TODO: work out what the response looks like
            req = Net::HTTP::Post.new(uri)
            req.body = body
            req.content_type = 'application/json'
            response = http.request(req)
            raise response.body unless response.kind_of? Net::HTTPSuccess
            data = JSON.parse(response.body)
            translated << data['text']
          end
          translated
        end
      end

    end # class
  end   # module
end
