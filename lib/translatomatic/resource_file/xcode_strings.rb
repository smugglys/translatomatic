module Translatomatic::ResourceFile

  # @!visibility private
  module XCodeStringsLocalePath

    # (see Translatomatic::ResourceFile::Base#locale_path)
    # @note localization files in XCode use the following file name
    #   convention: locale.lproj/filename
    def locale_path(locale)
      if path.to_s.match(/\b([-\w]+).lproj\/.+$/)
        # xcode style
        filename = path.basename
        path.parent.parent + (locale.to_s + ".lproj") + filename
      else
        super(locale)
      end
    end
  end

  # XCode strings resource file
  # @see https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html
  class XCodeStrings < Base
    include Translatomatic::ResourceFile::XCodeStringsLocalePath

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{strings}
    end

    # (see Translatomatic::ResourceFile::Base.is_key_value?)
    def self.is_key_value?
      true
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      out = ""
      out += comment(created_by) unless options[:no_created_by]
      properties.each do |key, value|
        key = escape(key)
        value = escape(value)
        out += %Q{"#{key}" = "#{value}";\n}
      end
      target.write(out)
    end

    private

    def load
      result = {}
      content = read_contents(@path)
      uncommented = content.gsub(/\/\*.*?\*\//, '')
      key_values = uncommented.scan(/"(.*?[^\\])"\s*=\s*"(.*?[^\\])"\s*;/m)
      key_values.each do |entry|
        key, value = entry
        result[unescape(key)] = unescape(value)
      end

      @properties = result
    end

    def comment(text)
      "/* #{text} */\n"
    end

    def unescape(string)
      string ? string.gsub(/\\(["'])/) { |i| i } : ''
    end

    def escape(string)
      string ? string.gsub(/["']/) { |i| "\\#{i}" } : ''
    end

  end
end
