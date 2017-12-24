module Translatomatic::Extractor
  class Base

    def initialize(path)
      @path = path.kind_of?(Pathname) ? path : Pathname.new(path)
      @contents = @path.read
    end

    def extract
      @contents.scan(/\"(.*?[^\\])"|'(.*?[^\\])'/).flatten.compact
    end

  end
end
