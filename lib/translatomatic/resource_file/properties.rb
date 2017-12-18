module Translatomatic::ResourceFile
  class Properties < Base

    def initialize(path)
      super(path)
      @language, @region = parse_language_region(path)
      @valid = true
      @format = :properties
      @properties = read(path)
    end

    def valid?
      @valid
    end

    def save
      out = ""
      properties.each do |key, value|
        value.gsub("\n", "\\n")  # convert newlines to \n
        out += "#{key} = #{value}\n"
      end
      # escape unicode characters
      out = EscapedUnicode.escape(out)
      File.open(path, "w") { |file| file.puts(out) }
    end

    private

    # detect language/region from filename
    def parse_language_region(path)
      basename = File.basename(path, ".properties")
      m = /strings_(\w+)(:?_(\w+))?/.match(basename)
      m ? m.captures : []
    end

    # parse key = value property file
    def read(path)
      contents = File.read(path)
      # convert escaped unicode characters into unicode
      contents = EscapedUnicode.unescape(contents)
      result = {}
      contents.gsub!(/\\\s*\n\s*/m, '')  # put multi line strings on one line
      lines = contents.split("\n")
      lines.each do |line|
        line.strip!
        next if line.length == 0
        unless line.index('=') > 0
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
