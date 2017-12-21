module Translatomatic
  class TranslationResult

    # Translation results
    # @return [Hash<String,String>] Translation results
    attr_reader :properties

    # @return [Locale] The locale of the original strings
    attr_reader :from_locale

    # @return [Locale] The target locale
    attr_reader :to_locale

    # Create a translation result
    # @param [Hash<String,String>] properties Untranslated properties
    # @param [Locale] from_locale The locale of the untranslated strings
    # @param [Locale] to_locale The target locale
    def initialize(properties, from_locale, to_locale)
      # find strings to send to translator
      # create a list of key, value. doesn't rely on hash ordering
      @key_values = []
      @properties = properties.dup
      @value_to_key = {}
      properties.each do |key, value|
        @key_values << [key, value]
        @value_to_key[value] = key
      end
      @from_locale = from_locale
      @to_locale = to_locale
    end

    # Retrieve a list of untranslated strings
    # @see update_db_strings
    # @return [Array<String>] A list of untranslated strings.
    def original_strings
      @key_values.collect { |k,v| v }
    end

    # Check if the result contains untranslated strings
    # @return [boolean] True if the result contains untranslated strings.
    def has_untranslated_strings?
      original_strings.length > 0
    end

    # Update result with a list of translated strings (from translator).
    # The strings must have the same length and order as {original_strings}
    # @param [Array<String>] list Translated strings
    # @return [void]
    def update_strings(list)
      raise "strings length mismatch" unless list.length == @key_values.length
      list = list.dup
      @key_values.each do |key, value|
        new_value = list.shift
        @properties[key] = new_value
      end
    end

    # Update result with texts from the database.
    # @note This modifies the return value of {original_strings},
    #   such that the list of {original_strings} no longer includes the
    #   strings from the database.
    # @param [Array<Translatomatic::Model::Text>] list Texts from database
    # @return [void]
    def update_db_strings(list)
      list.each do |t|
        original = t.from_text.value
        translated = t.value
        key = @value_to_key[original]
        raise "no key mapping for text '#{original}'" unless key
        @properties[key] = translated

        # remove entry from @key_values
        @key_values = @key_values.select { |k,v| k != key }
      end
    end

  end
end
