module Translatomatic
  module Translator

    class Google

      def initialize(config)
        key = config.google_api_key
        raise "google api key required" if key.nil?
        EasyTranslate.api_key = key
      end

      def translate(strings, from, to)
        return strings if from == to
        EasyTranslate.translate(strings, from: from, to: to)
      end

    end # class
  end   # module
end
