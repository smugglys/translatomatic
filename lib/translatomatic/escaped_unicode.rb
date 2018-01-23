module Translatomatic
  # Class to encode and decode unicode chars.
  # This code is highly influenced by Florian Frank's JSON gem
  # @see https://github.com/jnbt/java-properties
  # @see https://github.com/flori/json/
  class EscapedUnicode
    class << self
      # Decodes all unicode chars from escape sequences
      # @param text [String]
      # @return [String] The encoded text
      def unescape(text)
        string = text.gsub(/(?:\\[uU](?:[A-Fa-f\d]{4}))+/) do |c|
          unescape_char(c)
        end
        string.force_encoding(::Encoding::UTF_8)
        string
      end

      # Decodes all unicode chars into escape sequences
      # @param text [String]
      # @return [String] The decoded text
      def escape(text)
        string = text.dup
        string.force_encoding(::Encoding::ASCII_8BIT)
        string.gsub!(/["\\\x0-\x1f]/n) { |c| MAP[c] || c }
        string.gsub!(ESCAPE_REGEX) { |c| escape_char(c) }
        string.force_encoding(::Encoding::UTF_8)
        string
      end

      private

      def unescape_char(c)
        c.downcase!
        bytes = EMPTY_8BIT_STRING.dup
        i = 0
        while c[i] == '\\' && c[i + 1] == 'u'
          (1..2).each do |j|
            bytes << c[i + j * 2, 2].to_i(16)
          end
          i += 6
        end
        bytes.encode('utf-8', 'utf-16be')
      end

      def escape_char(c)
        (c.size == 1) && raise(t('unicode.invalid_byte', byte: c))
        s = c.encode('utf-16be', 'utf-8').unpack('H*')[0]
        s.force_encoding(::Encoding::ASCII_8BIT)
        s.gsub!(/.{4}/n, '\\\\u\&')
        s.force_encoding(::Encoding::UTF_8)
      end
    end

    # @private
    ESCAPE_REGEX = /(
      (?:
        [\xc2-\xdf][\x80-\xbf]    |
        [\xe0-\xef][\x80-\xbf]{2} |
        [\xf0-\xf4][\x80-\xbf]{3}
        )+ |
        [\x80-\xc1\xf5-\xff]       # invalid
        )/nx

    # @private
    MAP = {
      "\x0" => '\u0000',
      "\x1" => '\u0001',
      "\x2" => '\u0002',
      "\x3" => '\u0003',
      "\x4" => '\u0004',
      "\x5" => '\u0005',
      "\x6" => '\u0006',
      "\x7" => '\u0007',
      "\xb" => '\u000b',
      "\xe" => '\u000e',
      "\xf" => '\u000f',
      "\x10" => '\u0010',
      "\x11" => '\u0011',
      "\x12" => '\u0012',
      "\x13" => '\u0013',
      "\x14" => '\u0014',
      "\x15" => '\u0015',
      "\x16" => '\u0016',
      "\x17" => '\u0017',
      "\x18" => '\u0018',
      "\x19" => '\u0019',
      "\x1a" => '\u001a',
      "\x1b" => '\u001b',
      "\x1c" => '\u001c',
      "\x1d" => '\u001d',
      "\x1e" => '\u001e',
      "\x1f" => '\u001f'
    }.freeze
    private_constant :MAP

    # @private
    EMPTY_8BIT_STRING = ''.force_encoding(::Encoding::ASCII_8BIT).freeze
  end
end
