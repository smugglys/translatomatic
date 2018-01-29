require 'google_web_translate'

module Translatomatic
  module Provider
    # Google translation web interface.
    # supports multiple translations
    # @see https://translate.google.com.au
    class GoogleWeb < Base
      attr_accessor :dt

      # (see Base.supports_multiple_translations?)
      def self.supports_multiple_translations?
        true
      end

      # Create a new GoogleWeb provider instance
      def initialize(options = {})
        super(options)
        @dt = %w[t at]
        @debug = options[:debug]
      end

      # (see Base#languages)
      def languages
        api.respond_to?(:languages) ? api.languages : []
      end

      private

      def api
        options = { debug: @debug, dt: @dt, http_client: http_client }
        @api ||= GoogleWebTranslate::API.new(options)
      end

      def perform_translate(strings, from, to)
        strings.each do |string|
          result = api.translate(string, from, to)
          add_translations(string, translations_from_result(result))
        end
      end

      def translations_from_result(result)
        if result.alternatives.present?
          result.alternatives
        else
          result.translation
        end
      end
    end
  end
end
