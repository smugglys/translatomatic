module Translatomatic
  module Config
    # settings for a specific location
    # location can be user settings, project settings, or file specific
    # settings.
    class LocationSettings
      class << self
        # load settings from environment variables
        def from_environment
          settings = {}
          Options.options.each_value do |option|
            if option.env_name && ENV.include?(option.env_name)
              settings[option.name] = ENV[option.env_name]
            end
          end
          new(settings, location: :env)
        end
      end

      # @return [String] The path to the settings file
      attr_reader :path

      # @return [Symbol] The location of these settings (:user, :project, :env)
      attr_reader :location

      def initialize(data = {}, options = {})
        @data = data
        @options = options || {}
        @path = @options[:path]
        @location = @options[:location]
        @data[:files] ||= {}
      end

      # @return [String] Configuration as YAML
      def to_yaml
        @data.to_yaml
      end

      # Get per-file settings for the given path
      def for_file(for_file, location)
        file = Pathname.new(for_file)
        file = file.relative_path_from(@path) unless file.relative?
        data = @data[:files][file.to_s] ||= {}
        LocationSettings.new(data, path: @path, location: location)
      end

      # Get a configuration setting
      # @param key [String] configuration key
      # @return [String] The configuration value
      def get(key, default = nil)
        include?(key) ? @data[key.to_sym] : default
      end

      # Change a configuration setting.
      # @param key [String] configuration key
      # @param value [Object] new value for the configuration
      # @return [Object] the new value
      def set(key, value)
        update(key) { |option| @data[option.name] = cast(value, option.type) }
      end

      # Remove a configuration setting
      # @param key [String] configuration key to remove
      # @return [void]
      def unset(key)
        update(key) { |option| @data.delete(option.name) }
      end

      # If key is an array type, adds the value to the existing list.
      # Raises an error for non array types.
      # @param key [String] configuration key
      # @param value [Object] value to add to the list
      # @return [Object] the new value
      def add(key, value)
        update(key) do |option|
          assert_array_type(option)
          current_value = @data[option.name] || []
          @data[option.name] = current_value + cast(value, option.type)
        end
      end

      # If key is an array type, removes the value from the existing list.
      # Raises an error for non array types.
      # @param key [String] configuration key
      # @param value [Object] value to remove from the list
      # @return [Object] the new value
      def subtract(key, value)
        update(key) do |option|
          assert_array_type(option)
          current_value = @data[option.name] || []
          @data[option.name] = current_value - cast(value, option.type)
        end
      end

      # Test if configuration includes the given key
      # @param key [String] configuration key
      # @return [boolean] true if the configuration key is set
      def include?(key)
        Options.check_valid_key(key)
        @data.include?(key.to_sym)
      end

      private

      include Translatomatic::Util
      include Translatomatic::TypeCast

      # common functionality for set/unset/add/subtract methods
      def update(key)
        key = Options.check_valid_key(key)
        option = Options.options[key.to_sym]
        raise t('config.command_line_only') if option.command_line_only
        yield option
      end

      def assert_array_type(option)
        is_array = array_type?(option.type)
        raise t('config.non_array_key', key: option.name) unless is_array
      end
    end
  end
end
