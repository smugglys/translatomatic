module Translatomatic
  class Option
    attr_reader :name, :required, :use_env, :description

    def initialize(data = {})
      @name = data[:name]
      @required = data[:required]
      @use_env = data[:use_env]
      @description = data[:desc]
      @data = data
    end

    def to_hash
      @data
    end
  end

  module DefineOptions
    private
    def define_options(*options)
      @options = options.collect { |i| Translatomatic::Option.new(i) }
    end
  end
end
