module Translatomatic
  module Translator

    class Yandex

      def initialize(config)
        key = config.yandex_api_key
        raise "YANDEX_API_KEY required" if key.nil?
        @impl = Yandex::Translator.new(key)
      end

      def translate(strings, from, to)
        return strings if from == to

        translated = []
        strings.each do |string|
          value = value.gsub("\\n", "\n")      # convert \n to newlines first
          result = @impl.translate(string, from: from, to: to) || ""
          # convert newlines back to \n, with \ at end of lines
          result = result.gsub("\n", "\\n\\\n")
          translated.push(result)
        end
        translated
      end

    end # class
  end   # module
end
