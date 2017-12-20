module Translatomatic::ResourceFile
  class HTMLFile < Base

    def self.extensions
      %w{html htm shtml}
    end

    def initialize(path, locale = nil)
      super(path)
      @format = :html
      @valid = true
      @text = @path.exist? ? @path.read : nil
      @properties = { text: @text }
    end

    # index.html -> index.html.fr
    def locale_path(locale)
      extlist = extension_list(path)
      if extlist.length >= 2

      filename = path.basename.sub_ext('').sub(/_.*?$/, '').to_s
      filename += "_" + locale.to_s + path.extname
      path.dirname + filename
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
