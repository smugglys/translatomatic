require 'bing_translator'

module Translatomatic
  module Translator

    class Microsoft < Base

      define_options({
        name: :microsoft_api_key, desc: "Microsoft API key", use_env: true
        })

      def initialize(options = {})
        key = options[:microsoft_api_key] || ENV["MICROSOFT_API_KEY"]
        raise "microsoft api key required" if key.nil?
        @impl = BingTranslator.new(key)
      end

      # TODO: implement language list
      #def languages
      #end

      def perform_translate(strings, from, to)
        @impl.translate_array(strings, from: from.language, to: to.language)
      end

    end
  end
end
