require 'set'

module Translatomatic
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
    # @param [Hash<String,String>] properties Untranslated properties
    # @param [Locale] from_locale The locale of the untranslated strings
    # @param [Locale] to_locale The target locale
    def initialize(properties, from_locale, to_locale)
      @properties = properties.dup
      @value_to_keys = {}
      @untranslated = Set.new
      properties.each do |key, value|
        @untranslated << value
        keylist = (@value_to_keys[value] ||= [])
        keylist << key
      end
      @from_locale = from_locale
      @to_locale = to_locale
    end

    # Update result with a list of translated strings.
    # @param [Array<String>] original Original strings
    # @param [Array<String>] translated Translated strings
    # @return [void]
    def update_strings(original, translated)
      raise "strings length mismatch" unless original.length == translated.length
      original.zip(translated).each do |text1, text2|
        update(text1, text2)
      end
    end

    # Update result with texts from the database.
    # @param [Array<Translatomatic::Model::Text>] list Texts from database
    # @return [void]
    def update_db_strings(list)
      list.each do |t|
        original = t.from_text.value
        translated = t.value
        update(original, translated)
      end
    end

    private

    def update(original, translated)
      keys = @value_to_keys[original]
      raise "no key mapping for text '#{original}'" unless keys
      keys.each { |key| @properties[key] = translated }

      @untranslated.delete(original)
    end
  end
end
