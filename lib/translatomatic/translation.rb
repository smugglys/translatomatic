module Translatomatic
  # Data object describing a text translation
  class Translation
    # @return [Translatomatic::String] original string
    attr_reader :original

    # @return [Translatomatic::String] translated string
    attr_accessor :result

    # @return [Symbol] The name of the translator
    attr_reader :translator

    # @return [boolean] True if this translation came from the database
    attr_reader :from_database

    def initialize(original, result, options = {})
      @original = string(original)
      @result = string(result)
      @translator = options[:translator]
      @from_database = options[:from_database]
    end

    # Restore interpolated variable names in the translation
    # @param variable_regex [Regexp] Regexp used to match variable names
    # @return [boolean] True if variables were restored
    def restore_variables(variable_regex)
      # find variables in the original string
      vars1 = original.substrings(variable_regex)
      # find variables in the translated string
      vars2 = result.substrings(variable_regex)

      if vars1.length == vars2.length
        # we can restore variables. sort by largest offset first.
        # not using translation() method as that adds to @translations hash.
        conversions = vars1.zip(vars2).collect do |v1, v2|
          self.class.new(v1, v2)
        end
        conversions.sort_by! { |t| -t.original.offset }
        conversions.each do |conversion|
          v1 = conversion.original
          v2 = conversion.result
          result[v2.offset, v2.length] = v1.value
        end
      end
    end

    private

    def string(string)
      if string.is_a?(Translatomatic::String)
        string
      else
        Translatomatic::String.new(string, Locale.default)
      end
    end
  end
end
