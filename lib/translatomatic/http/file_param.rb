module Translatomatic
  module HTTP
    # Formats the contents of a file or string for a multipart post
    class FileParam < Param
      attr_accessor :filename, :content, :mime_type

      def initialize(key:, filename:, content:, mime_type:)
        @key = key
        @filename = filename
        @content = content
        @mime_type = mime_type
      end

      # (see Param#to_s)
      def to_s
        header(header_data) +
        header('Content-Type' => mime_type) + "\r\n#{content}\r\n"
      end

      private

      def header_data
        super.merge(filename: %("#{filename}"))
      end
    end
  end
end
