module Translatomatic::ResourceFile
  class Properties < Base

    def self.extensions
      %w{properties}
    end

    def initialize(path, locale = nil)
      super(path)
      @valid = true
      @format = :properties
      @properties = @path.exist? ? read(@path) : {}
    end

    def save
      out = ""
      properties.each do |key, value|
        value.gsub("\n", "\\n")  # convert newlines to \n
        out += "#{key} = #{value}\n"
      end
      # escape unicode characters
      out = Translatomatic::EscapedUnicode.escape(out)
      path.write(out)
    end

    private

    # parse key = value property file
    def read(path)
      contents = path.read
      # convert escaped unicode characters into unicode
      contents = Translatomatic::EscapedUnicode.unescape(contents)
      result = {}
      contents.gsub!(/\\\s*\n\s*/m, '')  # put multi line strings on one line
      lines = contents.split("\n")
      lines.each do |line|
        line.strip!
        next if line.length == 0
        unless line.index('=')
          @valid = false
          return {}
        end
        name, value = line.split(/\s*=\s*/, 2)
        value = value.gsub("\\n", "\n")      # convert \n to newlines
        result[name] = value
      end
      result
    end

  end
end
