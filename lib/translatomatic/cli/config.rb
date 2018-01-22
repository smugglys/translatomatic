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

      desc 'set key value', t('cli.config.set')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Change a configuration setting
      # @param key [String] configuration key
      # @param value [String] new value for the configuration
      # @return [String] the new value
      def set(key, *value)
        run { conf.set(key, value, config_location) }
      end

      desc 'unset key', t('cli.config.unset')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Remove a configuration setting
      # @param key [String] configuration key to remove
      # @return [void]
      def unset(key)
        run { conf.unset(key, config_location) }
      end

      desc 'add key value', t('cli.config.add')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Add a configuration setting to a list
      # @param key [String] configuration key
      # @param value [String] value to add
      # @return [String] the new value
      def add(key, *value)
        run { conf.add(key, value, config_location) }
      end

      desc 'subtract key value', t('cli.config.subtract')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      # Remove a configuration setting from a list
      # @param key [String] configuration key
      # @param value [String] value to remove
      # @return [void]
      def subtract(key, value)
        run { conf.subtract(key, value, config_location) }
      end

      desc 'list', t('cli.config.list')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Config)
      option :skip_blanks, type: :boolean, desc: 'Skip blank values'
      # List current configuration settings
      def list
        run do
          print_config_table(columns: %i[key value],
                             location: config_location,
                             skip_blanks: true)
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

      CONFIG_HEADING_MAP = {
        key: t('cli.config.name'),
        type: t('cli.config.type'),
        value: t('cli.config.value'),
        desc: t('cli.config.desc')
      }.freeze

      def config_location
        if options[:user] && options[:project]
          raise t('cli.config.one_at_a_time')
        elsif options[:user]
          :user
        elsif options[:project]
          :project
        end
      end

      def print_config_table(options)
        columns = options[:columns]
        location = options[:location]

        print_config_table_intro(location)
        print_config_table_body(columns, location)
      end

      def display_option?(option, location)
        key = option.name.to_s
        return false if option.command_line_only
        return false if options[:skip_blanks] && !conf.include?(key, location)
        true
      end

      def print_config_table_intro(location)
        if location
          puts t('cli.config.location_configuration', location: location)
        else
          puts t('cli.config.configuration')
        end
        puts
      end

      def print_config_table_body(columns, location)
        rows = config_table_rows(columns, location)

        if rows.empty?
          puts t('cli.config.no_config')
        else
          headings = columns.collect { |i| CONFIG_HEADING_MAP[i] }
          underscores = headings.collect { |i| i.gsub(/\w/, '=') }
          rows = [headings, underscores] + rows
          print_table(rows, indent: 2)
        end
        puts
      end

      def config_table_rows(columns, location)
        opts = Translatomatic::Config.options.select do |i|
          display_option?(i, location)
        end
        rows = opts.collect { |i| option_to_table_row(i, columns, location) }
        rows.sort_by { |i| i[0] }
        rows
      end

      def option_to_table_row(option, columns, location)
        row = []
        columns.each do |column|
          row << config_table_column_value(option, column, location)
        end
        row
      end

      def config_table_column_value(option, column, location)
        key = option.name.to_s

        case column
        when :key
          key
        when :value
          value = conf.get(key, location)
          value.nil? ? '-' : value
        when :type
          option.type_name
        when :desc
          option.description
        else
          raise "unhandled column type: #{column}"
        end
      end
    end
  end
end
