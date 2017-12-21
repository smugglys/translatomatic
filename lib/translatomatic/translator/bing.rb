require 'bing_translator'

module Translatomatic
  module Translator

    class Bing < Base

      define_options({
        name: :bing_api_key, desc: "Bing API key", use_env: true
        })

      def initialize(options = {})
        key = options[:bing_api_key] || ENV["BING_API_KEY"]
        raise "bing api key required" if key.nil?
        @impl = BingTranslator.new(key)
      end

      def perform_translate(strings, from, to)
        @impl.translate_array(strings, from: from.language, to: to.language)
      end

    end
  end
end
