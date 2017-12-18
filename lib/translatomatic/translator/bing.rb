require 'bing_translator'

module Translatomatic
  module Translator

    class Bing

      def initialize(config)
        key = config.bing_api_key
        raise "bing api key required" if key.nil?
        @impl = BingTranslator.new(key)
      end

      def translate(strings, from, to)
        return strings if from == to
        @impl.translate_array(strings, from: from.to_sym, to: to.to_sym)
      end

    end
  end
end
