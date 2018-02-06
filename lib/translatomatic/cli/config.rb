module Translatomatic
  module CLI
    # Configuration functions for the command line interface
    class Config < Base
      define_option :user, type: :boolean,
                           desc: t('cli.config.user'),
                           command_line_only: true
      define_option :project, type: :boolean,
                              desc: t('cli.config.project'),
                              command_line_only: true
      define_option :for_file, type: :path,
                               desc: t('cli.config.for_file'),
                               command_line_only: true

      desc 'set key value', t('cli.config.set')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Change a configuration setting
      # @param key [String] configuration key
      # @param value [String] new value for the configuration
      # @return [String] the new value
      def set(key, *value)
        run { conf.set(key, value, config_params) }
      end

      desc 'unset key', t('cli.config.unset')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Remove a configuration setting
      # @param key [String] configuration key to remove
      # @return [void]
      def unset(key)
        run { conf.unset(key, config_params) }
      end

      desc 'add key value', t('cli.config.add')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Add a configuration setting to a list
      # @param key [String] configuration key
      # @param value [String] value to add
      # @return [String] the new value
      def add(key, *value)
        run { conf.add(key, value, config_params) }
      end

      desc 'subtract key value', t('cli.config.subtract')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Remove a configuration setting from a list
      # @param key [String] configuration key
      # @param value [String] value to remove
      # @return [void]
      def subtract(key, value)
        run { conf.subtract(key, value, config_params) }
      end

      desc 'list', t('cli.config.list')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      option :skip_blanks, type: :boolean, desc: 'Skip blank values'
      # List current configuration settings
      def list
        run do
          print_config_table(columns: %i[key value], skip_blanks: true)
        end
      end

      desc 'describe', t('cli.config.describe')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Describe available configuration settings
      def describe
        run do
          print_config_table(columns: %i[key type desc])
        end
      end

      private

      def config_params
        { location: config_location, for_file: options['for-file'] }
      end

      def config_location
        if options[:user]
          :user
        elsif options[:project]
          :project
        end
      end

      def print_config_table(params)
        display_options = options.merge(params).merge(config_params)
        display = Translatomatic::Config::Display.new(display_options)
        puts config_table_intro + "\n"
        rows = display.config_table_body
        if rows.empty?
          puts t('cli.config.no_config')
        else
          print_table(rows)
        end
        puts
      end

      def config_table_intro
        if (location = config_location)
          t('cli.config.location_configuration', location: location)
        else
          t('cli.config.configuration')
        end
      end
    end
  end
end
