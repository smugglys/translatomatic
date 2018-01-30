module Translatomatic
  # A string object with an associated locale.
  class String
    # @return [String] The string
    attr_reader :value

    # @return [Translatomatic::Locale] The string's locale
    attr_reader :locale

    # @return [Translatomatic::String] If this string is a substring of
    #   another string, returns the original string. Otherwise, returns nil.
    attr_reader :parent

    # @return [Number] If this string is a substring of another string,
    #   returns the starting offset of this string in the original.
    attr_reader :offset

    # @return [String] Disambiguating context
    attr_accessor :context

    # @return [Regexp] Regexp that matches parts of the string to preserve
    attr_accessor :preserve_regex

    # Create a new string. Returns value if value is already a
    #   Translatomatic::String object with the same locale.
    def self.[](value, locale)
      if value.is_a?(Translatomatic::String) && value.locale == locale
        value
      else
        new(value, locale)
      end
    end

    # Creates a new string
    # @param value [String] A string
    # @param locale [String] A locale
    def initialize(value, locale, options = {})
      @value = value.to_s || ''
      @locale = Translatomatic::Locale.parse(locale)
      @offset = options[:offset] || 0
      @parent = options[:parent]
      @options = options
    end

    def dup
      copy = self.class.new(value, @locale, @options)
      copy.preserve_regex = preserve_regex
      copy.context = context
      copy
    end

    # Invokes value.match
    # @param pattern [Regexp,String] The regex pattern to match
    # @return [MatchData] Object describing the match, or nil if no match
    def match(pattern)
      @value.match(pattern)
    end

    # @return [boolean] true if this string is a substring of another string
    def substring?
      @parent ? true : false
    end

    # @return [String] The value of the string
    def to_s
      @value
    end

    # @return [Symbol] The type of string, corresponding to TMX segtype.
    # @see http://xml.coverpages.org/tmxSpec971212.html#SEGTYPE
    def type
      if sentences.length >= 2
        :paragraph
      else
        script = script_data
        @value.strip =~ /#{script.delimiter}\s*$/ ? :sentence : :phrase
      end
    end

    # Find all sentences in the string
    # @return [Array<Translatomatic::String] List of sentences
    def sentences
      substrings(sentence_regex)
    end

    # Find all substrings matching the given regex
    # @return [Array<Translatomatic::String] List of substrings
    def substrings(regex)
      matches = matches(@value, regex)
      strings = matches.collect { |i| match_to_substring(i) }.compact
      # return [self] if there's only one substring and it's equal to self
      strings.length == 1 && strings[0].eql?(self) ? [self] : strings
    end

    # @return [boolean] true if other is a {Translatomatic::String} with
    #   the same value and locale.
    def eql?(other)
      (other.is_a?(Translatomatic::String) || other.is_a?(::String)) &&
        other.hash == hash
    end

    # (see #eql?)
    def ==(other)
      eql?(other)
    end

    # @!visibility private
    def hash
      value.hash
      # [value, locale].hash
    end

    # Escape unprintable characters such as newlines.
    # @return [Translatomatic::String] The string with
    #   special characters escaped.
    def escape(skip = '')
      self.class.new(StringEscaping.escape(@value, skip), locale)
    end

    # Unescape character escapes such as "\n" to their character equivalents.
    # @return [Translatomatic::String] The string with
    #   escaped characters replaced with actual characters.
    def unescape
      self.class.new(StringEscaping.unescape(@value), locale)
    end

    private

    # @!visibility private
    class Script
      attr_reader :language
      attr_reader :delimiter      # sentence delimiter
      attr_reader :trailing_space # delimiter requires trailing space or eol
      attr_reader :left_to_right  # script direction

      def initialize(language:, delimiter:, trailing_space:, direction:)
        @language = language
        @delimiter = delimiter
        @trailing_space = trailing_space
        @left_to_right = direction == :ltr
        raise 'invalid direction' unless %i[ltr rtl].include?(direction)
      end
    end

    SCRIPT_DATA = [
      # [language, delimiter, trailing space, direction]
      # japanese, no space after
      ['ja', "\u3002", false, :ltr],
      # chinese, no space after
      ['zh', "\u3002", false, :ltr], # can be written any direction
      # armenian, space after
      ['hy', ':', true, :ltr],
      # hindi, space after
      ['hi', '।', true, :ltr],
      # urdu, space after, right to left
      ['ur', "\u06d4", true, :rtl],
      # thai, spaces used to separate sentences
      ['th', '\\s', false, :ltr],
      # arabic, right to left
      ['ar', '\\.', true, :rtl],
      # hebrew, right to left
      ['he', '\\.', true, :rtl],
      # all other languages
      ['default', '\\.', true, :ltr]
    ].freeze

    class << self
      attr_reader :script_data
    end

    begin
      script_data = {}
      SCRIPT_DATA.each do |lang, delimiter, trailing, ltr|
        script = Script.new(language: lang, delimiter: delimiter,
                            trailing_space: trailing, direction: ltr)
        script_data[lang] = script
      end
      @script_data = script_data
    end

    def match_to_substring(match)
      substring = match.to_s
      return nil if substring.empty?

      # find leading and trailing whitespace
      parts = substring.match(/\A(\s*)(.*?)(\s*)\z/m).to_a
      value = parts[2]
      offset = match.offset(0)[0]
      offset += parts[1].length # leading whitespace
      string = self.class.new(value, locale, offset: offset, parent: self)
      string.preserve_regex = preserve_regex
      string.context = context
      string
    end

    def matches(s, re)
      start_at = 0
      matches = []
      while (m = s.match(re, start_at))
        break if m.to_s.empty?
        matches.push(m)
        start_at = m.end(0)
      end
      matches
    end

    def sentence_regex
      script = script_data
      if script.trailing_space
        /.*?(?:#{script.delimiter}\s+|\z|\n)/m
      else
        # no trailing space after delimiter
        /.*?(?:#{script.delimiter}|\z|\n)/m
      end
    end

    def script_data
      data = self.class.script_data
      data[locale.language] || data['default']
    end

    def respond_to_missing?(name, include_private = false)
      @value.respond_to?(name) || super
    end

    def method_missing(name, *args)
      if @value.respond_to?(name)
        @value.send(name, *args)
      else
        super
      end
    end
  end
end
