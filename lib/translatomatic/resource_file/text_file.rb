module Translatomatic::ResourceFile
  class TextFile < Base

    def self.extensions
      %w{txt md text}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path)
      @format = :text
      @valid = true
      @text = @path.exist? ? @path.read : nil
      @properties = { text: @text }
    end

    # (see Translatomatic::ResourceFile::Base#get)
    def get(name)
      @text
    end

    # (see Translatomatic::ResourceFile::Base#set)
    def set(key, value)
      @text = value
      @properties[:text] = @text
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save
      path.write(@text)
    end
  end
end
