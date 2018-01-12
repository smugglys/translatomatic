require 'easy_translate'

module Translatomatic
  module Translator
    # Interface to the Google translation API
    # @see https://cloud.google.com/translate/
    class Google < Base
      define_option :google_api_key,
          desc: t('translator.google_api_key'), use_env: true

      # Create a new Google translator instance
      def initialize(options = {})
        super(options)
        key = options[:google_api_key] || ENV['GOOGLE_API_KEY']
        raise t('translator.google_key_required') if key.nil?
        EasyTranslate.api_key = key
      end

      # (see Translatomatic::Translator::Base#languages)
      def languages
        EasyTranslate::LANGUAGES.keys
      end

      private

      def perform_translate(strings, from, to)
        attempt_with_retries(3) do
          EasyTranslate.translate(strings, from: from.language, to: to.language)
        end
      end
    end
  end
end
