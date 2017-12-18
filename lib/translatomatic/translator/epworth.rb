module Translatomatic
  module Translator

    class Epworth

      def initialize(config)
        @random = Random.new
      end

      def translate(strings, from, to)
        return strings if from == to
        strings.map { |i| epworth(i) }
      end

      private

      def epworth(string)
        string.gsub(/\w/) { |i| random.rand(2) == 0 ? i.downcase : i.upcase }
      end

    end # class
  end   # module
end
