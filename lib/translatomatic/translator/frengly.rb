require 'net/http'

module Translatomatic
  module Translator

    class Frengly < Base

      define_options({
        name: :frengly_api_key, desc: "Frengly API key", use_env: true
      },
      { name: :frengly_email, desc: "Email address", use_env: true
      },
      { name: :frengly_password, desc: "Password", use_env: true
        })

        # Create a new Frengly translator instance
      def initialize(options = {})
        super(options)
        @key = options[:frengly_api_key] || ENV["FRENGLY_API_KEY"] # optional
        @email = options[:frengly_email]
        @password = options[:frengly_password]
        raise "email address required" unless @email
        raise "password required" unless @password
      end

      # (see Translatomatic::Translator::Base#languages)
      def languages
        ['en','fr','de','es','pt','it','nl','tl','fi','el','iw','pl','ru','sv']
      end

      private

      URL = 'http://frengly.com/frengly/data/translateREST'

      def perform_translate(strings, from, to)
        perform_fetch_translations(URL, strings, from, to)
      end

      def fetch_translation(request, string, from, to)
        body = {
          src: from.language,
          dest: to.language,
          text: string,
          email: @email,
          password: @password,
          premiumkey: @key
        }.to_json

        # TODO: work out what the response looks like
        response = request.post(body, content_type: 'application/json')
        data = JSON.parse(response.body)
        data['text']
      end

    end # class
  end   # module
end
