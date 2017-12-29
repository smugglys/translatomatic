module Translatomatic::Extractor
  # Base class for string extraction functionality
  class Base

    def initialize(path)
      @path = path.kind_of?(Pathname) ? path : Pathname.new(path)
      @contents = @path.read
    end

    # @return [Array<String>] All strings found
    def extract
      @contents.scan(/\"(.*?[^\\])"|'(.*?[^\\])'/).flatten.compact
    end

  end
end
