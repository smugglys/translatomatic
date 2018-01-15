
module Translatomatic::ResourceFile
  # Properties resource file
  # @see https://docs.oracle.com/javase/tutorial/essential/environment/properties.html
  class Properties < Base
    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w[properties]
    end

    # (see Translatomatic::ResourceFile::Base.is_key_value?)
    def self.is_key_value?
      true
    end

    # (see Translatomatic::ResourceFile::Base.supports_variable_interpolation?)
    def self.supports_variable_interpolation?
      true
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      out = ''
      out += add_created_by unless options[:no_created_by]
      properties.each do |key, value|
        next if value.nil?
        # escape newlines etc in the value
        value = Translatomatic::StringEscaping.escape(value)
        out += "#{key} = #{value}\n"
      end
      # escape unicode characters
      out = Translatomatic::EscapedUnicode.escape(out)
      target.write(out)
    end

    # (see Translatomatic::ResourceFile::Base#create_variable)
    def create_variable(name)
      "{#{name}}"
    end

    # (see Translatomatic::ResourceFile::Base#variable_regex)
    def variable_regex
      /\{.*?\}/
    end

    private

    def load
      @properties = read_properties
    end

    def add_created_by
      comment(created_by)
    end

    def comment(text)
      "# #{text}\n"
    end

    def read_properties
      contents = read_contents(@path)
      # convert escaped unicode characters into unicode
      contents = Translatomatic::EscapedUnicode.unescape(contents)
      result = {}
      contents.gsub!(/\\\s*\n\s*/m, '') # put multi line strings on one line
      lines = contents.split("\n")

      lines.each do |line|
        line.strip!
        next if line.empty?
        equal_idx = line.index('=')
        colon_idx = line.index(':')

        if line[0] == '!' || line[0] == '#'
          # comment
          # TODO: translate comments or keep originals?
          next
        elsif equal_idx.nil? && colon_idx.nil?
          # TODO: throw exception here?
          return {}
        end
        name, value = line.split(/\s*[=:]\s*/, 2)
        # convert escaped newlines to newlines
        value = Translatomatic::StringEscaping.unescape(value)
        result[name] = value
      end
      result
    end
  end
end
