module Translatomatic
  # String escaping/unescaping code from syck/encoding.rb
  module StringEscaping
    ESCAPES = %w[\x00 \x01 \x02 \x03 \x04 \x05 \x06 \a
                 \x08 \t \n \v \f
                 \r \x0e \x0f
                 \x10 \x11 \x12 \x13 \x14 \x15 \x16 \x17
                 \x18 \x19 \x1a \e \x1c \x1d \x1e \x1f].freeze
    UNESCAPES = {
      'a' => "\x07", 'b' => "\x08", 't' => "\x09",
      'n' => "\x0a", 'v' => "\x0b", 'f' => "\x0c",
      'r' => "\x0d", 'e' => "\x1b", '\\' => '\\'
    }.freeze

    class << self
      # Escape unprintable characters such as newlines.
      # @param value [String] The string to escape
      # @param skip [String] Characters to not escape
      # @return [String] The string with special characters escaped.
      def escape(value, skip = '')
        value.gsub(/\\/, '\\\\\\')
             .gsub(/"/, '\\"')
             .gsub(/([\x00-\x1f])/) do
          skip[$&] || ESCAPES[ $&.unpack('C')[0] ]
        end
      end

      # Unescape character escapes such as "\n" to their character equivalents.
      # @param value [String] The string to unescape
      # @return [String] The string with special characters unescaped.
      def unescape(value)
        regex = /\\(?:([nevfbart\\])|0?x([0-9a-fA-F]{2})|u([0-9a-fA-F]{4}))/
        value.gsub(regex) do
          if Regexp.last_match(3)
            [Regexp.last_match(3).to_s.hex].pack('U*')
          elsif Regexp.last_match(2)
            [Regexp.last_match(2)].pack('H2')
          else
            UNESCAPES[Regexp.last_match(1)]
          end
        end
      end

      def unquote(value)
        if value && value[0] == value[-1] && %w[' "].include?(value[0])
          value[1...-1]
        else
          value
        end
      end
    end
  end
end
