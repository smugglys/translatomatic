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

    # @return [boolean] True if this option can only be set in the
    #   user configuration file
    attr_reader :user_location_only

    # Create a new option
    # @param attributes [Hash<Symbol,Object>] Attributes as above
    # @return [Translatomatic::Option] A new option instance
    def initialize(attributes = {})
      attributes.each do |k, v|
        raise "unrecognised attribute #{k}" unless constructor_option?(k)
        instance_variable_set("@#{k}", v)
      end
      @description = @desc
      @type ||= :string
      raise "invalid type: #{@type}" unless VALID_TYPES.include?(@type)
      @env_name ||= @use_env && @name ? @name.to_s.upcase : nil
    end

    def to_thor
      {
        required: @required,
        type: thor_type,
        desc: @description,
        default: @default,
        aliases: @aliases,
        banner: type_name,
        enum: @enum ? @enum.collect(&:to_s) : nil
      }
    end

    def type_name
      t("config.types.#{type}")
    end

    # Retrieve all options from an object or list of objects.
    # @param object [#options,Array<#options>] Options source
    # @return [Array<Translatomatic::Option>] options
    def self.options_from_object(object)
      if object.is_a?(Translatomatic::Option)
        [object]
      elsif object.respond_to?(:options)
        options_from_object(object.options)
      elsif object.is_a?(Array)
        object.collect { |i| options_from_object(i) }.flatten
      else
        []
      end
    end

    private

    include Util

    CONSTRUCTOR_OPTIONS = %i[name required desc use_env hidden type default
                             aliases enum user_location_only
                             command_line_only env_name].freeze
    VALID_TYPES = %i[array path_array string path boolean numeric].freeze

    def constructor_option?(key)
      CONSTRUCTOR_OPTIONS.include?(key)
    end

    def thor_type
      case @type
      when :array, :path_array, :string, :path
        # use internal ',' splitting for array types on command line
        :string
      else
        @type
      end
    end
  end
end
