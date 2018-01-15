module Translatomatic::CLI
  # Configuration functions for the command line interface
  class Config < Base
    define_option :context, type: :string, aliases: '-c',
                            desc: t('cli.config.context'),
                            enum: Translatomatic::Config::CONTEXTS,
                            command_line_only: true

    desc 'set key value', t('cli.config.set')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Change a configuration setting
    # @param key [String] configuration key
    # @param value [String] new value for the configuration
    # @return [String] the new value
    def set(key, *value)
      run { conf.set(key, value, cli_option(:context)) }
    end

    desc 'unset key', t('cli.config.unset')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Remove a configuration setting
    # @param key [String] configuration key to remove
    # @return [void]
    def unset(key)
      run { conf.unset(key, cli_option(:context)) }
    end

    desc 'add key value', t('cli.config.add')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Add a configuration setting to a list
    # @param key [String] configuration key
    # @param value [String] value to add
    # @return [String] the new value
    def add(key, *value)
      run { conf.add(key, value, cli_option(:context)) }
    end

    desc 'subtract key value', t('cli.config.subtract')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Remove a configuration setting from a list
    # @param key [String] configuration key
    # @param value [String] value to remove
    # @return [void]
    def subtract(key, value)
      run { conf.subtract(key, value, cli_option(:context)) }
    end

    desc 'list', t('cli.config.list')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    option :skip_blanks, type: :boolean, desc: 'Skip blank values'
    # List current configuration settings
    def list
      run do
        print_config_table(columns: %i[key value],
                           context: cli_option(:context),
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

    def print_config_table(options)
      columns = options[:columns]
      context = options[:context]

      print_config_table_intro(context)
      print_config_table_body(columns, context)
    end

    def display_option?(option, context)
      key = option.name.to_s
      return false if option.command_line_only
      return false if options[:skip_blanks] && !conf.include?(key, context)
      true
    end

    def print_config_table_intro(context)
      if context
        puts t('cli.config.context_configuration', context: context)
      else
        puts t('cli.config.configuration')
      end
      puts
    end

    def print_config_table_body(columns, context)
      rows = config_table_rows(columns, context)

      if rows.empty?
        puts t('cli.config.no_config')
      else
        headings = columns.collect { |i| CONFIG_HEADING_MAP[i] }
        rows.unshift headings.collect { |i| i.gsub(/\w/, '=') }
        rows.unshift headings
        print_table(rows, indent: 2)
      end
      puts
    end

    def config_table_rows(columns, context)
      opts = Translatomatic::Config.options.select do |i|
        display_option?(i, context)
      end
      rows = opts.collect { |i| option_to_table_row(i, columns, context) }
      rows.sort_by { |i| i[0] }
      rows
    end

    def option_to_table_row(option, columns, context)
      key = option.name.to_s
      row = []
      columns.each do |column|
        row << case column
               when :key
                 key
               when :value
                 value = conf.get(key, context)
                 value.nil? ? '-' : value
               when :type
                 t("config.types.#{option.type}")
               when :desc
                 option.description
        end
      end
      row
    end
  end
end
