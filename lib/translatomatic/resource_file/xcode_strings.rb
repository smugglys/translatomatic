module Translatomatic::ResourceFile
  # XCode strings resource file
  # @see https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html
  class XCodeStrings < Base
    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w[strings]
    end

    # (see Translatomatic::ResourceFile::Base.is_key_value?)
    def self.is_key_value?
      true
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      out = ''
      out += comment(created_by) unless options[:no_created_by]
      properties.each do |key, value|
        key = escape(key)
        value = escape(value)
        out += %("#{key}" = "#{value}";\n)
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
