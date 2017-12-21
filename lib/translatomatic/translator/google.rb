module Translatomatic
  module Translator

    class Google < Base

      define_options({ name: :google_api_key, desc: "Google API key",
            use_env: true
          })

      def initialize(options = {})
        key = options[:google_api_key] || ENV["GOOGLE_API_KEY"]
        raise "google_api_key required" if key.nil?
        EasyTranslate.api_key = key
      end

      def languages
        # TODO: check that this returns an array of languages
        EasyTranslate.translations_available
      end

      def perform_translate(strings, from, to)
        EasyTranslate.translate(strings, from: from.language, to: to.language)
      end

    end # class
  end   # module
end
