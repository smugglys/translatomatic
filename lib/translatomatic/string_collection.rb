module Translatomatic
  # A collection of strings
  class StringCollection
    attr_reader :originals

    def initialize(strings = [])
      strings = [strings] unless strings.is_a?(Array)
      strings = strings.select { |i| translatable?(i) }
      strings = stringify(strings) # convert to String objects
      @originals = strings
      @sentences = find_sentences(strings) # convert to sentences
      contexts = find_contexts(strings)
      @all_strings = @sentences + contexts
      group_by_locale(@all_strings)
    end

    # Iterate over strings in the collection grouped by locale
    def each_locale
      @by_locale.each do |locale, list|
        yield locale, list
      end
    end

    # @return [Number] The total number of strings in the collection,
    #   equal to the number of sentences and context strings.
    def count
      @all_strings.length
    end

    private

    def translatable?(string)
      # don't translate numbers
      string && !string.match(/\A\s*\z/) && !string.match(/\A[\d,]+\z/)
    end

    def stringify(strings)
      strings.collect { |i| to_string(i) }
    end

    def find_sentences(strings)
      strings.collect { |i| i.sentences }.flatten
    end

    def find_contexts(strings)
      strings.collect { |i| context_to_string(i) }.flatten.uniq.compact
    end

    def context_to_string(string)
      string.context ? to_string(string.context, string.locale) : nil
    end

    def group_by_locale(strings)
      @by_locale = {}
      strings.each do |string|
        list = @by_locale[string.locale] ||= []
        list << string
      end
    end

    def to_string(value, locale = Locale.default)
      if value.is_a?(Translatomatic::String)
        value
      else
        Translatomatic::String.new(value, locale)
      end
    end
  end
end
