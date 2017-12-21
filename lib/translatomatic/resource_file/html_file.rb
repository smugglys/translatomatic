module Translatomatic::ResourceFile
  class HTMLFile < Base

    def self.extensions
      %w{html htm shtml}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path)
      @format = :html
      @valid = true
      @text = @path.exist? ? @path.read : nil
      @properties = { text: @text }
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
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
