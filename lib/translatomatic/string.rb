module Translatomatic
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

    def initialize(value, locale, options = {})
      @value = value || ''
      @locale = Translatomatic::Locale.parse(locale)
      @offset = options[:offset] || 0
      @parent = options[:parent]
    end

    # @return [String] The value of the string
    def to_s
      @value
    end

    def length
      @value.length
    end

    def empty?
      @value.empty?
    end

    def match(regex)
      @value.match(regex)
    end

    # @return [boolean] true if this string is a substring of another string
    def substring?
      @parent ? true : false
    end

    # @return [Symbol] The type of string, corresponding to TMX segtype.
    # @see http://xml.coverpages.org/tmxSpec971212.html#SEGTYPE
    def type
      if sentences.length >= 2
        :paragraph
      else
        script = script_data
        @value.strip.match(/#{script.delimiter}\s*$/) ? :sentence : :phrase
      end
    end

    # Find all sentences in the string
    # @return [Array<Translatomatic::String] List of sentences
    def sentences
      sentences = @value.scan(sentence_regex)
      strings = []
      offset = 0
      sentences.each do |sentence|
        # find leading and trailing whitespace
        parts = sentence.match(/^(\s*)(.*?)(\s*)$/).to_a
        value = parts[2]
        offset += parts[1].length  # leading whitespace
        strings << self.class.new(value, locale, offset: offset, parent: self)
        offset += value.length + parts[3].length
      end

      # return [self] if there's only one sentence and it's equal to self
      strings.length == 1 && strings[0].eql?(self) ? [self] : strings
    end

    def eql?(other)
      other.kind_of?(Translatomatic::String) && other.hash == hash
    end

    def ==(other)
      eql?(other)
    end

    def hash
      [value, locale].hash
    end

    private

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
        raise "invalid direction" unless [:ltr, :rtl].include?(direction)
      end
    end

    SCRIPT_DATA = [
      # [language, delimiter, trailing space, direction]
      # japanese, no space after
      ["ja", "\u3002", false, :ltr],
      # chinese, no space after
      ["zh", "\u3002", false, :ltr],  # can be written any direction
       # armenian, space after
      ["hy", ":", true, :ltr],
      # hindi, space after
      ["hi", "।", true, :ltr],
      # urdu, space after, right to left
      ["ur", "\u06d4", true, :rtl],
      # thai, spaces used to separate sentences
      ["th", "\\s", false, :ltr],
      # arabic, right to left
      ["ar", "\\.", true, :rtl],
      # hebrew, right to left
      ["he", "\\.", true, :rtl],
      # all other languages
      ["default", "\\.", true, :ltr],
    ]

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

    def sentence_regex
      script = script_data
      if script.trailing_space
        regex = /.+?(?:#{script.delimiter}\s+|$)/
      else
        # no trailing space after delimiter
        regex = /.+?(?:#{script.delimiter}|$)/
      end
    end

    def script_data
      data = self.class.script_data
      data[locale.language] || data["default"]
    end

  end
end
