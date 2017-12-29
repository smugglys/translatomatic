require 'set'

module Translatomatic
  # Stores results of a translation
  class TranslationResult

    # Translation results
    # @return [Hash<String,String>] Translation results
    attr_reader :properties

    # @return [Locale] The locale of the original strings
    attr_reader :from_locale

    # @return [Locale] The target locale
    attr_reader :to_locale

    # @return [Set<String>] Untranslated strings
    attr_reader :untranslated

    # Create a translation result
    # @param properties [Hash<String,String>] Untranslated properties
    # @param from_locale [Locale] The locale of the untranslated strings
    # @param to_locale [Locale] The target locale
    def initialize(properties, from_locale, to_locale)
      @value_to_keys = {}
      @untranslated = Set.new
      @from_locale = from_locale
      @to_locale = to_locale

      # duplicate strings
      @properties = properties.transform_values { |i| i.dup }

      properties.each do |key, value|
        # split property value into sentences
        string = string(value, from_locale)
        string.sentences.each do |sentence|
          @untranslated << sentence
          keylist = (@value_to_keys[sentence.to_s] ||= [])
          keylist << key
        end
      end
    end

    # Update result with a list of translated strings.
    # @param original [Array<String>] Original strings
    # @param translated [Array<String>] Translated strings
    # @return [void]
    def update_strings(original, translated)
      raise "strings length mismatch" unless original.length == translated.length
      conversions(original, translated).each do |text1, text2|
        update(text1, text2)
      end
    end

    # @param original [Array<String>] Original strings
    # @param translated [Array<String>] Translated strings
    # @return [Array<Array<String>>] A list of conversions in the form
    #   [[original, translated], ...]
    def conversions(original, translated)
      # create list of [from, to] text conversions
      conversions = []
      original.zip(translated).each do |text1, text2|
        conversions << [text1, text2]
      end

      # sort conversion list by largest offset first so that we replace
      # from the end of the string to the front, so substring offsets
      # are correct in the target string.
      conversions.sort_by! do |t1, t2|
        t1.respond_to?(:offset) ? -t1.offset : 0
      end
      conversions
    end

    private

    include Translatomatic::Util

    def update(original, translated)
      keys = @value_to_keys[original.to_s]
      raise "no key mapping for text '#{original}'" unless keys
      keys.each do |key|
        if original.kind_of?(Translatomatic::String) && original.substring?
          @properties[key][original.offset, original.length] = translated
        else
          @properties[key] = translated
        end
      end

      @untranslated.delete(original)
    end
  end
end
