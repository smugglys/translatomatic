module Translatomatic
  # A collection of texts
  class TextCollection
    attr_reader :originals

    def initialize(texts = [])
      texts = [texts] unless texts.is_a?(Array)
      texts = texts.select { |i| translatable?(i) }
      texts = textify(texts) # convert to Text objects
      @originals = texts
      @sentences = find_sentences(texts) # convert to sentences
      contexts = find_contexts(texts)
      @all_texts = @sentences + contexts
      group_by_locale(@all_texts)
    end

    # Iterate over texts in the collection grouped by locale
    def each_locale
      @by_locale.each do |locale, list|
        yield locale, list
      end
    end

    # @return [Number] The total number of texts in the collection,
    #   equal to the number of sentences and context strings.
    def count
      @all_texts.length
    end

    private

    def translatable?(text)
      # don't translate numbers
      text && !text.match(/\A\s*\z/) && !text.match(/\A[\d,]+\z/)
    end

    def textify(texts)
      texts.collect { |i| build_text(i) }
    end

    def find_sentences(texts)
      texts.collect(&:sentences).flatten.uniq
    end

    def find_contexts(texts)
      texts.collect { |i| build_text(i.context) }.flatten.uniq.compact
    end

    def group_by_locale(texts)
      @by_locale = {}
      texts.each do |text|
        list = @by_locale[text.locale] ||= []
        list << text
      end
    end

    def build_text(value, locale = Locale.default)
      return nil if value.nil?
      if value.is_a?(Translatomatic::Text)
        value
      else
        Translatomatic::Text.new(value, locale)
      end
    end
  end
end
