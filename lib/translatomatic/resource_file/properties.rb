
module Translatomatic
  module ResourceFile
    # Properties resource file
    # @see https://docs.oracle.com/javase/tutorial/essential/environment/properties.html
    class Properties < Base
      # (see Base.extensions)
      def self.extensions
        %w[properties]
      end

      # (see Base.key_value?)
      def self.key_value?
        true
      end

      # (see Base.supports_variable_interpolation?)
      def self.supports_variable_interpolation?
        true
      end

      # (see Base#save)
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

      # (see Base#create_variable)
      def create_variable(name)
        "{#{name}}"
      end

      # (see Base#variable_regex)
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
        lines.each { |line| parse_line(line, result) }
        result
      end

      def parse_line(line, result)
        line.strip!
        return if line.empty?

        # comment - TODO: keep comments
        return if line[0] == '!' || line[0] == '#'

        name, value = line.split(/\s*[=:]\s*/, 2)
        return unless name && value

        # convert escaped newlines to newlines
        value = Translatomatic::StringEscaping.unescape(value)
        result[name] = value
      end
    end
  end
end
