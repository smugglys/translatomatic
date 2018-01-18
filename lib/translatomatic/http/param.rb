module Translatomatic
  module HTTP
    # Formats a basic string key/value pair for a multipart post
    class Param
      attr_accessor :key, :value

      def initialize(key:, value:)
        @key = key
        @value = value
      end

      # @return [String] Representation of this parameter as it appears
      #   within a multipart post request.
      def to_s
        header(header_data) + "\r\n#{value}\r\n"
      end

      private

      def header_data
        name = CGI.escape(key.to_s)
        { 'Content-Disposition' => 'form-data', name: %("#{name}") }
      end

      def header(options)
        out = []
        idx = 0
        options.each do |key, value|
          separator = idx.zero? ? ': ' : '='
          out << "#{key}#{separator}#{value}"
          idx += 1
        end
        out.join('; ') + "\r\n"
      end
    end
  end
end
