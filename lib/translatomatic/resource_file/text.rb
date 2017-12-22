module Translatomatic::ResourceFile
  class Text < Base

    def self.extensions
      %w{txt md text}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path, locale)
      @valid = true
      @properties = @path.exist? ? read(@path) : {}
    end

    # (see Translatomatic::ResourceFile::Base#save(target))
    def save(target = path)
      values = @properties.values.collect { |i| i.strip + "\n" }
      target.write(values.join)
    end

    private

    def read(path)
      text = path.read
      { "text" => text }
    end
  end
end
