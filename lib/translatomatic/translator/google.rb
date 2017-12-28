module Translatomatic
  module Translator

    class Google < Base

      define_options({ name: :google_api_key, desc: "Google API key",
            use_env: true
          })

      # Create a new Google translator instance
      def initialize(options = {})
        key = options[:google_api_key] || ENV["GOOGLE_API_KEY"]
        raise "google api key required" if key.nil?
        EasyTranslate.api_key = key
      end

      # (see Translatomatic::Translator::Base#languages)
      def languages
        EasyTranslate::LANGUAGES.keys
      end

      private

      def perform_translate(strings, from, to)
        EasyTranslate.translate(strings, from: from.language, to: to.language)
      end

    end # class
  end   # module
end
