module Translatomatic
  module Config
    # Configuration file operations.
    # Configuration settings may be specified in the following locations:
    #
    #  - environment variables
    #  - user configuration file $HOME/.translatomatic/config.yml
    #  - project configuration file $PROJECT/.translatomatic/config.yml
    #  - command line options
    #
    # Settings are read in the order given above, with last setting found
    # taking precedence over values read earlier.
    class Files
      class << self
        # Save location settings to file
        # @param settings [LocationSettings] Location settings object
        # @return [void]
        def save(settings)
          return unless settings && settings.path
          FileUtils.mkdir_p(File.dirname(settings.path))
          File.write(settings.path, settings.to_yaml)
        end

        # load configuration from the yaml file at path.
        # @param path to config file
        # @return [LocationSettings] Location settings object
        def load(path, options = {})
          return nil unless path
          config_path = File.join(path, SETTINGS_PATH)
          options = options.merge(path: config_path)
          return new_settings({}, options) unless File.exist?(config_path)
          config = YAML.load_file(config_path) || {}
          new_settings(config, options)
        end

        # find a project directory working upwards from current directory.
        # stop at user path.
        def find_project(user_path)
          user_path = user_path.to_s
          Pathname.new(Dir.pwd).ascend do |v|
            return nil if v.to_s == user_path || user_path.start_with?(v.to_s)
            settings_path = v + SETTINGS_DIR
            return v if settings_path.directory?
          end
          nil
        end

        private

        SETTINGS_DIR = '.translatomatic'.freeze
        SETTINGS_PATH = File.join(SETTINGS_DIR, 'config.yml').freeze

        def new_settings(config, options = {})
          LocationSettings.new(config.deep_symbolize_keys, options)
        end
      end
    end
  end
end
