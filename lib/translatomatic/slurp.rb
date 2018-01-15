module Translatomatic
  # Class for slurping files
  class Slurp
    class << self
      # Slurp a file, convert to UTF-8
      # @param path [String] Path to a file
      # @return [String] file contents in UTF-8
      def read(path)
        # read data
        data = File.read(path)
        encoding = detect_encoding(data)
        data.force_encoding(encoding) if encoding
        data.encode!(Encoding::UTF_8)
        data
      end

      private

      # detect encoding using CharDet
      # returns nil if unknown encoding
      def detect_encoding(data)
        # detect encoding
        cd = CharDet.detect(data)
        encoding = cd['encoding']
        confidence = cd['confidence']

        Encoding.find(encoding) if encoding && confidence >= 0.5
      end
    end
  end
end
