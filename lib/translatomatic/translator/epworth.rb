module Translatomatic
  module Translator

    class Epworth < Base

      def initialize(options = {})
        @random = Random.new
      end

      def perform_translate(strings, from, to)
        strings.map { |i| epworth(i) }
      end

      private

      def epworth(string)
        string.gsub(/\w/) { |i| random.rand(2) == 0 ? i.downcase : i.upcase }
      end

    end # class
  end   # module
end
