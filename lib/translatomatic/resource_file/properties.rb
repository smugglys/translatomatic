require 'date'

module Translatomatic::ResourceFile
  # Properties resource file
  # @see https://docs.oracle.com/javase/tutorial/essential/environment/properties.html
  class Properties < Base

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{properties}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path, locale)
      @valid = true
      @properties = @path.exist? ? read(@path) : {}
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      out = ""
      out += add_created_by unless options[:no_created_by]
      properties.each do |key, value|
        # TODO: maintain original line ending format?
        value = value.gsub("\n", "\\n")  # convert newlines to \n
        out += "#{key} = #{value}\n"
      end
      # escape unicode characters
      out = Translatomatic::EscapedUnicode.escape(out)
      target.write(out)
    end

    # (see Translatomatic::ResourceFile::Base#supports_variable_interpolation?)
    def supports_variable_interpolation?
      true
    end

    # (see Translatomatic::ResourceFile::Base#variable)
    def variable(name)
      return "{#{name}}"
    end

    private

    def add_created_by
      comment(created_by)
    end

    def comment(text)
      "# #{text}\n"
    end

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
        equal_idx = line.index("=")

        if line[0] == ?! || line[0] == ?#
          # comment
          # TODO: translate comments or keep originals?
          next
        elsif equal_idx.nil?
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
