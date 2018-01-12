require 'set'

module Translatomatic
  # Stores results of a translation
  class TranslationResult
    # @return [Translatomatic::ResourceFile::Base] The resource file
    attr_reader :file

    # @return [Hash<String,String>] Translation results
    attr_reader :properties

    # @return [Locale] The locale of the original strings
    attr_reader :from_locale

    # @return [Locale] The target locale
    attr_reader :to_locale

    # @return [Set<String>] Untranslated strings
    attr_reader :untranslated

    # Create a translation result
    # @param file [Translatomatic::ResourceFile::Base] A resource file
    # @param to_locale [Locale] The target locale
    def initialize(file, to_locale)
      @file = file
      @value_to_keys = {}
      @untranslated = Set.new
      @translations = []
      @from_locale = file.locale
      @to_locale = to_locale

      # duplicate strings
      @properties = file.properties.transform_values(&:dup)

      @properties.each do |key, value|
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
    # @param translations [Array<Translatomatic::Translation>] Translations
    # @return [void]
    def add_translations(translations)
      translations.each do |t|
        @translations << t
        @untranslated.delete(t.original) unless t.result.nil?
      end
    end

    # Apply translations to the result properties.
    def apply!
      # sort translation list by largest offset first so that we replace
      # from the end of the string to the front, so substring offsets
      # are correct in the target string.
      list = @translations.sort_by { |t| -t.original.offset }
      list.each do |translation|
        update(translation.original, translation.result)
      end
      @translations = []
    end

    private

    include Translatomatic::Util

    # update properties
    def update(original, translated)
      keys = @value_to_keys[original.to_s]
      raise "no key mapping for text '#{original}'" unless keys
      keys.each do |key|
        # value = @properties[key]
        if original.is_a?(Translatomatic::String) && original.substring?
          # log.debug("#{value[original.offset, original.length]} -> #{translated}")
          @properties[key][original.offset, original.length] = translated
        else
          # log.debug("#{key} -> #{translated}")
          @properties[key] = translated
        end
      end
    end
  end
end
