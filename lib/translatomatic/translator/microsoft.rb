require 'bing_translator'

module Translatomatic
  module Translator

    # Interface to the Microsoft translation API
    # @see https://www.microsoft.com/en-us/translator/translatorapi.aspx
    class Microsoft < Base

      define_options({
        name: :microsoft_api_key, desc: t("translator.microsoft_api_key"), use_env: true
        })

      # Create a new Microsoft translator instance
      def initialize(options = {})
        super(options)
        key = options[:microsoft_api_key] || ENV["MICROSOFT_API_KEY"]
        raise t("translator.microsoft_key_required") if key.nil?
        @impl = BingTranslator.new(key)
      end

      # TODO: implement language list
      # (see Translatomatic::Translator::Base#languages)
      #def languages
      #end

      private

      def perform_translate(strings, from, to)
        @impl.translate_array(strings, from: from.language, to: to.language)
      end

    end
  end
end
