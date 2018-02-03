module Translatomatic
  module Config
    # Translatomatic configuration settings.
    # get and set methods accept a params hash, which recognises the
    # following keys:
    # * location: [Symbol] configuration location (:user or :project)
    # * for_file: [String] file path for per-file configuration
    class Settings
      # @return [String] The path to the user home
      attr_reader :user_path

      # @return [String] The path to the project home
      attr_reader :project_path

      def initialize(options = {})
        @user_path = File.realpath(options[:user_path] || Dir.home)
        @project_path = options[:project_path] || Files.find_project(@user_path)
        load
      end

      # Get a configuration setting
      # @param key [String] configuration key
      # @param params [Hash] options
      # @return [String] The configuration value. If location is nil, returns the
      #   effective value by precedence, otherwise it returns the setting for
      #   the given configuration file location.
      def get(key, params = {})
        option = Options.option(key)
        settings = settings_read(key, params)
        value = settings ? settings.get(key, option.default) : option.default

        # cast value to expected type.
        base_path = config_base_path(settings.location) if settings
        cast(value, option.type, base_path: base_path)
      end

      # Change a configuration setting.  By default the project configuration
      #   file is changed if a project configuration file exists,
      #   otherwise the user configuration file is changed.
      # @param key [String] configuration key
      # @param params [Hash] options
      # @return [void]
      def set(key, value, params = {})
        settings_write(key, params).set(key, value)
        save
      end

      # Remove a configuration setting
      # @param key [String] configuration key to remove
      # @param params [Hash] options
      # @return [void]
      def unset(key, params = {})
        settings_write(key, params).unset(key)
        save
      end

      # If key is an array type, adds the value to the existing list.
      # Raises an error for non array types.
      # @param key [String] configuration key
      # @param value [Object] value to add to the list
      # @param params [Hash] options
      # @return [void]
      def add(key, value, params = {})
        settings_write(key, params).add(key, value)
        save
      end

      # If key is an array type, removes the value from the existing list.
      # Raises an error for non array types.
      # @param key [String] configuration key
      # @param value [Object] value to remove from the list
      # @param params [Hash] options
      # @return [void]
      def subtract(key, value, params = {})
        settings_write(key, params).subtract(key, value)
        save
      end

      # Get all configuration settings
      # @param params [Hash] options
      def all(params = {})
        settings = {}
        Options.options.each_value do |option|
          settings[option.name] = get(option.name, params)
        end
        settings
      end

      # Test if configuration includes the given key
      # @param key [String] configuration key
      # @param params [Hash] options
      # @return [boolean] true if the configuration key is set
      def include?(key, params = {})
        settings = settings_read(key, params)
        settings && settings.include?(key)
      end

      private

      include Translatomatic::Util
      include Translatomatic::TypeCast

      # Save configuration settings
      def save
        Files.save(@settings[:user])
        Files.save(@settings[:project])
      end

      # Load configuration from the config file(s)
      def load
        @settings = {}
        @settings[:env] = LocationSettings.from_environment
        @settings[:user] = Files.load(@user_path, location: :user)
        @settings[:project] = Files.load(@project_path, location: :project)
      end

      def settings_write(key, params = {})
        selector = Selector.new(@settings, default_location, params)
        selector.settings_for_write(key)
      end

      def settings_read(key, params = {})
        selector = Selector.new(@settings, default_location, params)
        selector.settings_for_read(key)
      end

      def default_location
        # use project location if we have project configuration
        @project_path ? :project : :user
      end

      # return base path for the config file at the given location
      def config_base_path(location)
        case location
        when :user
          user_path
        when :project
          project_path
        end
      end
    end
  end
end
