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

    def initialize(original, result, translator = nil, from_database = false)
      @original = original
      @result = result
      @translator = translator
      @from_database = from_database
    end

    private

    def string(string)
      string.is_a?(Translatomatic::String) ? string : Translatomatic::String.new(string)
    end
  end
end
