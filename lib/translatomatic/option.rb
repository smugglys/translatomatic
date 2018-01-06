module Translatomatic
  # Stores details about command line and object constructor options
  class Option
    # @return [String] Name of the option
    attr_reader :name

    # @return [boolean] True if this option is required
    attr_reader :required

    # @return [String] If set, the name of the environment variable
    #   that can be used to set this option in the environment.
    attr_reader :env_name

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

    # @return [boolean] True if this option can only be set on the command line
    attr_reader :command_line_only

    # @return [boolean] True if this option can only be set in user context
    attr_reader :user_context_only

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
      @aliases = data[:aliases]
      @enum = data[:enum]
      @user_context_only = data[:user_context_only]
      @command_line_only = data[:command_line_only]
      @env_name = data[:env_name] || (@use_env ? @name.to_s.upcase : nil)
    end

    def to_thor
      # use internal ',' splitting for array types on command line
      type = @type == :array ? :string : @type

      { name: @name,
        required: @required,
        type: type,
        desc: @description,
        default: @default,
        aliases: @aliases,
        enum: @enum ? @enum.collect { |i| i.to_s } : nil
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
end
