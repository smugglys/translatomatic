require 'google_web_translate'

module Translatomatic
  module Translator
    # Google translation web interface.
    # supports multiple translations
    # @see https://translate.google.com.au
    class GoogleWeb < Base
      attr_accessor :dt

      # Create a new GoogleWeb translator instance
      def initialize(options = {})
        super(options)
        @dt = %w[t at]
      end

      # (see Base#languages)
      def languages
        EasyTranslate::LANGUAGES.keys
      end

      def api
        @api ||= GoogleWebTranslate::API.new(debug: options[:debug], dt: @dt)
      end

      private

      def perform_translate(strings, from, to)
        translated = []
        strings.each do |string|
          attempt_with_retries(3) do
            result = api.translate(string, from, to)
            translated << result.translation
          end
        end
        translated
      end
    end
  end
end
