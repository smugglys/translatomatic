require 'yandex-translator'

module Translatomatic
  module Translator

    class Yandex < Base

      def initialize(options = {})
        key = options[:yandex_api_key] || ENV["YANDEX_API_KEY"]
        raise "yandex_api_key required" if key.nil?
        @impl = ::Yandex::Translator.new(key)
      end

      def languages
        @languages ||= @impl.langs.collect { |i| i[0, 2] }.uniq
      end

      def perform_translate(strings, from, to)
        translated = []
        strings.each do |string|
          result = @impl.translate(string, from: from.language, to: to.language) || ""
          translated.push(result)
        end
        translated
      end

    end # class
  end   # module
end
