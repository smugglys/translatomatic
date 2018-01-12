require 'net/http'

module Translatomatic
  module Translator
    # Interface to the Frengly translation API
    # @see http://www.frengly.com/api
    class Frengly < Base
      define_option :frengly_api_key, use_env: true,
                    desc: t('translator.frengly_api_key')
      define_option :frengly_email, use_env: true,
                    desc: t('translator.email_address')
      define_option :frengly_password, use_env: true,
                    desc: t('translator.password')

      # Create a new Frengly translator instance
      def initialize(options = {})
        super(options)
        @key = options[:frengly_api_key] || ENV['FRENGLY_API_KEY'] # optional
        @email = options[:frengly_email]
        @password = options[:frengly_password]
        raise t('translator.email_required') unless @email
        raise t('translator.password_required') unless @password
      end

      # (see Translatomatic::Translator::Base#languages)
      def languages
        %w[en fr de es pt it nl tl fi el iw pl ru sv]
      end

      private

      URL = 'http://frengly.com/frengly/data/translateREST'.freeze

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
    end
  end
end
