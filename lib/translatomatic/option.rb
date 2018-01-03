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

    # @return [boolean] If true, the option does not appear on the command line
    #   but it can be used in configuration settings
    attr_reader :hidden

    # @return [Symbol] Type of option, one of:
    #   :string, :hash, :array, :numeric, or :boolean
    attr_reader :type

    # @return [Object] The default value for this option
    attr_reader :default

    # Create a new option
    # @param data [Hash<Symbol,Object>] Attributes as above
    # @return [Translatomatic::Option] A new option instance
    def initialize(data = {})
      @name = data[:name]
      @required = data[:required]
      @description = data[:desc]
      @use_env = data[:use_env]
      @hidden = data[:hidden]
      @type = data[:type] || :string
      @default = data[:default]

      if @use_env && @default.nil?
        env_name = @name.to_s.upcase
        @default = ENV[env_name]
      end
    end

    def to_thor
      # use internal ',' splitting for array types on command line
      type = @type == :array ? :string : @type

      { name: @name,
        required: @required,
        type: type,
        desc: @description,
        default: @default
      }
    end

    # Retrieve all options from an object or list of objects.
    # @param object [#options,Array<#options>] Options source
    # @return [Array<Translatomatic::Option>] options
    def self.options_from_object(object)
      options = []
      if object.respond_to?(:options)
        options += options_from_object(object.options)
      elsif object.kind_of?(Array)
        object.each do |item|
          if item.kind_of?(Translatomatic::Option)
            options << item
          elsif item.respond_to?(:options)
            options += options_from_object(item.options)
          end
        end
      end
      options
    end
  end

  private

  # @!visibility private
  module DefineOptions

    # @!visibility private
    module ClassMethods
      attr_reader :options

      private

      def define_options(*options)
        @options = options.collect { |i| Translatomatic::Option.new(i) }
      end
    end

    private

    def self.included(klass)
      klass.extend(ClassMethods)
    end
  end
end
