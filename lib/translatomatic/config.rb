module Translatomatic
  # Translatomatic configuration.
  # Configuration settings may be specified in the following locations:
  #
  #  - environment variables
  #  - user configuration file $HOME/.translatomatic/config.yml
  #  - project configuration file $PROJECT/.translatomatic/config.yml
  #  - command line options
  #
  # Settings are read in the order given above, with last setting found
  # taking precedence over values read earlier.
  class Config
    # @return [Logger] The logger instance
    attr_accessor :logger

    # @return [String] The path to the user settings file
    attr_reader :user_settings_path

    # @return [String] The path to the project settings file
    attr_reader :project_settings_path

    # Change a configuration setting.  The default context is project level
    #   if a project configuration file exists, otherwise user level.
    # @param key [String] configuration key
    # @param value [Object] new value for the configuration
    # @param context [Symbol] configuration context
    # @return [Object] the new value
    def set(key, value, context = nil)
      set_or_add(key, value, context, :set)
    end

    # Remove a configuration setting
    # @param key [String] configuration key to remove
    # @param context [Symbol] configuration context
    # @return [void]
    def unset(key, context = nil)
      unset_or_subtract(key, nil, context, :unset)
    end

    # If key is an array type, adds the value to the existing list.
    # Raises an error for non array types.
    # @param key [String] configuration key
    # @param value [Object] value to add to the list
    # @param context [Symbol] configuration context
    # @return [Object] the new value
    def add(key, value, context = nil)
      set_or_add(key, value, context, :add)
    end

    # If key is an array type, removes the value from the existing list.
    # Raises an error for non array types.
    # @param key [String] configuration key
    # @param value [Object] value to remove from the list
    # @param context [Symbol] configuration context
    # @return [Object] the new value
    def subtract(key, value, context = nil)
      unset_or_subtract(key, value, context, :subtract)
    end

    # Get a configuration setting
    # @param key [String] configuration key
    # @param context [Symbol] configuration context. May be nil.
    # @return [String] The configuration value. If context is nil, returns the
    #   effective value by precedence, otherwise it returns the setting for
    #   the given context.
    def get(key, context = nil)
      key = check_valid_key(key)
      option = option(key)
      value = option.default # set to default value

      if context.nil?
        # find the first setting in the following order
        CONTEXTS.each do |ctx|
          if @settings[ctx].include?(key)
            value = @settings[ctx][key]
            break
          end
        end
      else
        # context is set
        context = check_valid_context(context)
        value = @settings[context][key] if @settings[context].include?(key)
      end

      # cast value to expected type
      cast_get(value, option.type, context)
    end

    # Get all configuration settings
    def all(context = nil)
      settings = {}
      self.class.options.each do |option|
        settings[option.name] = get(option.name, context)
      end
      settings
    end

    # Test if configuration includes the given key
    # @param key [String] configuration key
    # @return [String] The configuration value. If context is nil, checks
    #   all contexts.
    # @return [boolean] true if the configuration key is set
    def include?(key, context = nil)
      key = check_valid_key(key)
      if context.nil?
        CONTEXTS.each do |ctx|
          return true if @settings[ctx].include?(key)
        end
        false
      else
        context = check_valid_context(context)
        @settings[context].include?(key)
      end
    end

    # Save configuration settings
    def save
      save_with_context(:user, @user_settings_path)
      save_with_context(:project, @project_settings_path)
    end

    # Load configuration from the config file(s)
    def load
      load_context_env
      load_with_context(:user, @user_settings_path)
      load_with_context(:project, @project_settings_path)
    end

    # Reset all configuration to the defaults
    def reset
      @settings = {}
      CONTEXTS.each { |context| @settings[context] = {} }
    end

    # @return [Array<Translatomatic::Option] all available options
    def self.options
      config_options.values
    end

    # The project path is found by searching for a '.translatomatic' directory
    # that is not within the user home directory. The search ascends upwards
    # from the current working directory.
    # @return The path to the current project, or nil if the current project
    #   path is unknown.
    def project_path
      return nil unless @project_settings_path
      File.absolute_path(File.join(File.dirname(@project_settings_path), '..'))
    end

    private

    include Translatomatic::Util
    include Translatomatic::TypeCast

    SETTINGS_DIR = '.translatomatic'.freeze
    SETTINGS_PATH = File.join(SETTINGS_DIR, 'config.yml')
    USER_SETTINGS_PATH = File.join(Dir.home, SETTINGS_PATH)

    # valid context list in order of precedence
    CONTEXTS = %i[project user env].freeze

    class << self
      def config_sources
        [
          Translatomatic::CLI::CommonOptions,
          Translatomatic::CLI::Translate,
          Translatomatic::CLI::Config,
          Translatomatic::Translator.modules,
          Translatomatic::Database,
          Translatomatic::Converter
        ].freeze
      end

      # @return [Hash<String,Translatomatic::Option>] options
      def config_options
        @config_options ||= begin
          # create mapping from option name to option object
          map = {}
          config_sources.each do |source|
            source_options = Translatomatic::Option.options_from_object(source)
            source_options.each do |sopt|
              optname = sopt.name.to_sym
              raise "#{optname} already defined" if map.include?(optname)
              map[optname] = sopt
            end
          end
          map
        end
      end
    end

    def set_or_add(key, value, context, mode)
      update(key, context, mode) do |option, ctx|
        casted_value = cast(value, option.type)
        if mode == :add
          current_value = @settings[ctx][option.name] || []
          casted_value = current_value + casted_value
        end
        @settings[ctx][option.name] = casted_value
      end
    end

    def unset_or_subtract(key, value, context, mode)
      update(key, context, mode) do |option, ctx|
        if mode == :subtract
          casted_value = cast(value, option.type)
          current_value = @settings[ctx][option.name] || []
          casted_value = current_value - casted_value
          @settings[ctx][option.name] = casted_value
        else
          @settings[ctx].delete(option.name)
        end
      end
    end

    # common checks for set/unset/add/subtract methods
    def update(key, context, mode)
      key = check_valid_key(key)
      option = option(key)
      check_valid_update(option, mode)

      context ||= default_context
      context = :user if option.user_context_only || key.to_s.match(/api_key/)
      context = check_valid_context(context)
      result = yield option, context
      save
      result
    end

    def check_valid_update(option, mode)
      raise t('config.command_line_only') if option.command_line_only

      if (mode == :add || mode == :subtract) && !array_type?(option.type)
        raise t('config.non_array_key', key: option.name)
      end
    end

    def save_with_context(context, path)
      return unless path
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.puts @settings[context].to_yaml }
    end

    # load configuration from the yaml file at path
    def load_with_context(context, path)
      return unless path && File.exist?(path)
      config = YAML.load_file(path) || {}
      load_context_config(context, config)
    end

    # load configuration from a hash
    def load_context_config(context, config = {})
      config.each do |key, value|
        key = key.to_sym
        next unless valid_key?(key)
        @settings[context][key] = value
      end
    end

    # load configuration from environment variables
    def load_context_env
      config = {}
      self.class.options.each do |option|
        if option.env_name && ENV.include?(option.env_name)
          config[option.name] = ENV[option.env_name]
        end
      end
      load_context_config(:env, config)
    end

    # cast used on get only.
    # we only resolve paths for get because we want to keep relative paths
    # in the config file.
    def cast_get(value, type, context)
      value = cast(value, type)

      case type
      when :path_array
        value.collect { |i| cast_get(i, :path, context) }
      when :path
        File.absolute_path(cast_path(value), context_path(context))
      else
        value
      end
    end

    # return path relative to the given context configuration file
    def context_path(context)
      case context
      when :user
        File.join(File.dirname(user_settings_path), '..')
      when :project
        project_path
      end
    end

    def option(key)
      self.class.config_options[key.to_sym]
    end

    def check_valid_key(key)
      key = key ? key.to_sym : nil
      raise t('config.invalid_key', key: key) unless valid_key?(key)
      key
    end

    def check_valid_context(context)
      context = context ? context.to_sym : nil
      valid = valid_context?(context)
      raise t('config.invalid_context', context: context) unless valid
      context
    end

    def valid_key?(key)
      self.class.config_options.include?(key)
    end

    def valid_context?(context)
      CONTEXTS.include?(context)
    end

    # override user settings path, used for testing
    def user_settings_path=(path)
      reset
      @user_settings_path = path
      load
    end

    # override project settings path, used for testing
    def project_settings_path=(path)
      reset
      @project_settings_path = path
      load
    end

    def initialize
      @logger = Translatomatic::Logger.new
      @user_settings_path = USER_SETTINGS_PATH
      @project_settings_path = find_project_settings
      reset
      load
    end

    # find a .translatomatic directory working upwards from current directory
    def find_project_settings
      found = nil
      Pathname.new(Dir.pwd).ascend do |v|
        if found.nil?
          settings_path = v + SETTINGS_DIR
          # set found if we found a .translatomatic directory
          found = v + SETTINGS_PATH if settings_path.directory?
        end
      end
      # if found path is the same as the user settings path, don't use it
      found && found.to_s == @user_settings_path ? nil : found
    end

    def default_context
      # use project context if we have project configuration
      @project_settings_path ? :project : :user
    end
  end
end
