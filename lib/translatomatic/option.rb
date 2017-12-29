module Translatomatic
  # Stores details about command line and object constructor options
  class Option
    # @return [String] Name of the option
    attr_reader :name

    # @return [boolean] True if this option is required
    attr_reader :required

    # @return [boolean] If true, the option can be set via an environment
    #   variable corresponding to the uppercased version of {name}.
    attr_reader :use_env

    # @return [String] Description of the option
    attr_reader :description

    # Create a new option
    # @param data [Hash<Symbol,Object>] Attributes as above
    # @return [Translatomatic::Option] A new option instance
    def initialize(data = {})
      @name = data[:name]
      @required = data[:required]
      @use_env = data[:use_env]
      @description = data[:desc]
      @data = data
    end

    # @return [Hash] Option data as a hash
    def to_hash
      @data
    end
  end

  private

  # @!visibility private
  module DefineOptions
    private
    def define_options(*options)
      @options = options.collect { |i| Translatomatic::Option.new(i) }
    end
  end
end
