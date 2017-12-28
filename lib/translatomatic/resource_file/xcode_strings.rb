module Translatomatic::ResourceFile

  # XCode strings file
  # @see https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html
  class XCodeStrings < Base

    def self.extensions
      %w{strings}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path, locale)
      @valid = true
      @properties = @path.exist? ? read(@path) : {}
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
    # @note localization files in XCode use the following file name
    #   convention: Project/locale.lproj/filename
    def locale_path(locale)
      if path.to_s.match(/\/([-\w]+).lproj\/.+.strings$/)
        # xcode style
        filename = path.basename
        path.parent.parent + (locale.to_s + ".lproj") + filename
      else
        super(locale)
      end
    end

    # (see Translatomatic::ResourceFile::Base#save(target))
    def save(target = path)
      out = ""
      properties.each do |key, value|
        key = escape(key)
        value = escape(value)
        out += %Q{"#{key}" = "#{value}";\n}
      end
      target.write(out)
    end

    private

    def read(path)
      result = {}
      content = path.read
      uncommented = content.gsub(/\/\*.*?\*\//, '')
      key_values = uncommented.scan(/"(.*?[^\\])"\s*=\s*"(.*?[^\\])"\s*;/m)
      key_values.each do |entry|
        key, value = entry
        result[unescape(key)] = unescape(value)
      end
      result
    end

    def unescape(string)
      string ? string.gsub(/\\(["'])/) { |i| i } : ''
    end

    def escape(string)
      string ? string.gsub(/["']/) { |i| "\\#{i}" } : ''
    end

  end
end
