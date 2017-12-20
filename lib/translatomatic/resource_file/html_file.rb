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
      extlist = extension_list
      if extlist.length >= 2
        # two or more parts to extension
        tag = extlist.find { |i| valid_locale?(i) }
        if tag
          # part of the extension is the locale
          # replace that part with the new locale
          idx = extlist.index(tag)
          extlist[idx] = locale.to_s
          new_extension = extlist.join(".")
          return strip_extensions.sub_ext("." + new_extension)
        end
      end

      # fall back to base functionality
      super(locale)
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
