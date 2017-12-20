module Translatomatic
  class TranslationResult

    attr_reader :properties
    attr_reader :from_locale
    attr_reader :to_locale

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

    def original_strings
      @key_values.collect { |k,v| v }
    end

    def has_untranslated_strings?
      original_strings.length > 0
    end

    # update data with a list of translated strings (from translator)
    # the strings must have the same length and order as @key_values
    def update_strings(list)
      raise "strings length mismatch" unless list.length == @key_values.length
      list = list.dup
      @key_values.each do |key, value|
        new_value = list.shift
        @properties[key] = new_value
      end
    end

    # update data with list of texts from database
    # list is an array of Translatomatic::Model::Text objects
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
