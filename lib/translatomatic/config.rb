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

    # Change a configuration setting.  By default is the project configuration
    #   file is changed if a project configuration file exists,
    #   otherwise the user configuration file is changed.
    # @param key [String] configuration key
    # @param value [Object] new value for the configuration
    # @param location [Symbol] configuration location (:user or :project)
    # @return [Object] the new value
    def set(key, value, location = nil)
      set_or_add(key, value, location, :set)
    end

    # Remove a configuration setting
    # @param key [String] configuration key to remove
    # @param location [Symbol] configuration location (:user or :project)
    # @return [void]
    def unset(key, location = nil)
      unset_or_subtract(key, nil, location, :unset)
    end

    # If key is an array type, adds the value to the existing list.
    # Raises an error for non array types.
    # @param key [String] configuration key
    # @param value [Object] value to add to the list
    # @param location [Symbol] configuration location (:user or :project)
    # @return [Object] the new value
    def add(key, value, location = nil)
      set_or_add(key, value, location, :add)
    end

    # If key is an array type, removes the value from the existing list.
    # Raises an error for non array types.
    # @param key [String] configuration key
    # @param value [Object] value to remove from the list
    # @param location [Symbol] configuration location (:user or :project)
    # @return [Object] the new value
    def subtract(key, value, location = nil)
      unset_or_subtract(key, value, location, :subtract)
    end

    # Get a configuration setting
    # @param key [String] configuration key
    # @param location [Symbol] configuration location (:user or :project)
    # @return [String] The configuration value. If location is nil, returns the
    #   effective value by precedence, otherwise it returns the setting for
    #   the given configuration file location.
    def get(key, location = nil)
      key = check_valid_key(key)
      option = option(key)
      value = option.default # set to default value

      if location.nil?
        # find the first setting in the following order
        LOCATIONS.each do |ctx|
          if @settings[ctx].include?(key)
            value = @settings[ctx][key]
            break
          end
        end
      else
        # location is set
        location = check_valid_location(location)
        value = @settings[location][key] if @settings[location].include?(key)
      end

      # cast value to expected type
      cast_get(value, option.type, location)
    end

    # Get all configuration settings
    def all(location = nil)
      settings = {}
      self.class.options.each do |option|
        settings[option.name] = get(option.name, location)
      end
      settings
    end

    # Test if configuration includes the given key
    # @param key [String] configuration key
    # @return [String] The configuration value. If location is nil, checks
    #   all locations.
    # @return [boolean] true if the configuration key is set
    def include?(key, location = nil)
      key = check_valid_key(key)
      if location.nil?
        LOCATIONS.each do |ctx|
          return true if @settings[ctx].include?(key)
        end
        false
      else
        location = check_valid_location(location)
        @settings[location].include?(key)
      end
    end

    # Save configuration settings
    def save
      save_with_location(:user, @user_settings_path)
      save_with_location(:project, @project_settings_path)
    end

    # Load configuration from the config file(s)
    def load
      load_env
      load_with_location(:user, @user_settings_path)
      load_with_location(:project, @project_settings_path)
    end

    # Reset all configuration to the defaults
    def reset
      @settings = {}
      LOCATIONS.each { |location| @settings[location] = {} }
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

    # valid location list in order of precedence
    LOCATIONS = %i[project user env].freeze

    class << self
      # @private
      def config_sources
        [
          Translatomatic::CLI::CommonOptions,
          Translatomatic::CLI::Translate,
          Translatomatic::CLI::Config,
          Translatomatic::Provider.types,
          Translatomatic::ResourceFile.types,
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

    def set_or_add(key, value, location, mode)
      update(key, location, mode) do |option, ctx|
        casted_value = cast(value, option.type)
        if mode == :add
          current_value = @settings[ctx][option.name] || []
          casted_value = current_value + casted_value
        end
        @settings[ctx][option.name] = casted_value
      end
    end

    def unset_or_subtract(key, value, location, mode)
      update(key, location, mode) do |option, ctx|
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
    def update(key, location, mode)
      key = check_valid_key(key)
      option = option(key)
      check_valid_update(option, mode)

      location ||= default_location
      location = :user if option.user_location_only || key.to_s.match(/api_key/)
      location = check_valid_location(location)
      result = yield option, location
      save
      result
    end

    def check_valid_update(option, mode)
      raise t('config.command_line_only') if option.command_line_only

      if (mode == :add || mode == :subtract) && !array_type?(option.type)
        raise t('config.non_array_key', key: option.name)
      end
    end

    def save_with_location(location, path)
      return unless path
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') { |f| f.puts @settings[location].to_yaml }
    end

    # load configuration from the yaml file at path
    def load_with_location(location, path)
      return unless path && File.exist?(path)
      config = YAML.load_file(path) || {}
      load_location_config(location, config)
    end

    # load configuration from a hash
    def load_location_config(location, config = {})
      config.each do |key, value|
        key = key.to_sym
        next unless valid_key?(key)
        @settings[location][key] = value
      end
    end

    # load configuration from environment variables
    def load_env
      config = {}
      self.class.options.each do |option|
        if option.env_name && ENV.include?(option.env_name)
          config[option.name] = ENV[option.env_name]
        end
      end
      load_location_config(:env, config)
    end

    # cast used on get only.
    # we only resolve paths for get because we want to keep relative paths
    # in the config file.
    def cast_get(value, type, location)
      value = cast(value, type)

      case type
      when :path_array
        value.collect { |i| cast_get(i, :path, location) }
      when :path
        File.absolute_path(cast_path(value), location_path(location))
      else
        value
      end
    end

    # return path relative to the given configuration file
    def location_path(location)
      case location
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

    def check_valid_location(location)
      location = location ? location.to_sym : nil
      valid = valid_location?(location)
      raise t('config.invalid_location', location: location) unless valid
      location
    end

    def valid_key?(key)
      self.class.config_options.include?(key)
    end

    def valid_location?(location)
      LOCATIONS.include?(location)
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

    def default_location
      # use project location if we have project configuration
      @project_settings_path ? :project : :user
    end
  end
end
