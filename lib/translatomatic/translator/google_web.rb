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
        @debug = options[:debug]
      end

      # (see Base#languages)
      def languages
        api.respond_to?(:languages) ? api.languages : []
      end

      def api
        options = { debug: @debug, dt: @dt, http_client: http_client }
        @api ||= GoogleWebTranslate::API.new(options)
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
