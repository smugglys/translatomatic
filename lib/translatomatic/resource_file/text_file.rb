module Translatomatic::ResourceFile
  class TextFile < Base

    def self.extensions
      %w{txt md text}
    end

    def initialize(path, locale = nil)
      super(path)
      @format = :text
      @locale = locale
      @valid = true
      @text = File.read(path)
      @properties = { text: @text }
    end

    def get(name)
      @text
    end

    def set(key, value)
      @text = value
      @properties[:text] = @text
    end

    def save
      path.write(@text)
    end
  end
end
