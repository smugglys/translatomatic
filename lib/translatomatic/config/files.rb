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
          config_path = File.join(settings.path, CONFIG_PATH)
          FileUtils.mkdir_p(File.dirname(config_path))
          File.write(config_path, settings.to_yaml)
        end

        # load configuration from the yaml file at path.
        # @param path to config file
        # @return [LocationSettings] Location settings object
        def load(path, options = {})
          return nil unless path
          config_path = File.join(path, CONFIG_PATH)
          options = options.merge(path: path)
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
            config_path = v + CONFIG_DIR
            return v if config_path.directory?
          end
          nil
        end

        private

        CONFIG_DIR = '.translatomatic'.freeze
        CONFIG_PATH = File.join(CONFIG_DIR, 'config.yml').freeze

        def new_settings(config, options = {})
          LocationSettings.new(config.deep_symbolize_keys, options)
        end
      end
    end
  end
end
