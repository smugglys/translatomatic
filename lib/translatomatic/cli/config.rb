module Translatomatic::CLI
  # Configuration functions for the command line interface
  class Config < Base

    define_options(
      { name: :context, type: :string, aliases: "-c",
        desc: t("cli.config.context"),
        enum: Translatomatic::Config::CONTEXTS,
        command_line_only: true
      },
    )

    desc "set key value", t("cli.config.set")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Change a configuration setting
    # @param key [String] configuration key
    # @param value [String] new value for the configuration
    # @return [String] the new value
    def set(key, *value)
      run { conf.set(key, value, cli_option(:context)) }
    end

    desc "add key value", t("cli.config.add")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Change a configuration setting
    # @param key [String] configuration key
    # @param value [String] value to add to the configuration
    # @return [String] the new value
    def set(key, *value)
      run { conf.add(key, value, cli_option(:context)) }
    end

    desc "remove key", t("cli.config.remove")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Remove a configuration setting
    # @param key [String] configuration key to remove
    # @return [void]
    def remove(key)
      run { conf.remove(key, cli_option(:context)) }
    end

    desc "list", t("cli.config.list")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # List current configuration settings
    def list
      run do
        print_config_table(columns: [:key, :value],
          context: cli_option(:context),
          skip_blanks: true
        )
      end
    end

    desc "describe", t("cli.config.describe")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Config)
    # Describe available configuration settings
    def describe
      run do
        print_config_table(columns: [:key, :type, :desc])
      end
    end

    private

    CONFIG_HEADING_MAP = {
      key: t("cli.config.name"),
      type: t("cli.config.type"),
      value: t("cli.config.value"),
      desc: t("cli.config.desc"),
    }

    def print_config_table(options)
      columns = options[:columns]
      context = options[:context]
      rows = []

      if context
        puts t("cli.config.context_configuration", context: context)
      else
        puts t("cli.config.configuration")
      end
      puts
      Translatomatic::Config.options.each do |option|
        key = option.name.to_s
        next if option.command_line_only
        next if options[:skip_blanks] && !conf.include?(key, context)
        value = conf.get(key, context)
        data = []
        columns.each do |column|
          data << case column
          when :key
            key
          when :value
            value.nil? ? "-" : value
          when :type
            t("config.types.#{option.type}")
          when :desc
            option.description
          end
        end
        rows << data
      end

      if rows.empty?
        puts t("cli.config.no_config")
      else
        rows.sort_by { |i| i[0] }
        headings = columns.collect { |i| CONFIG_HEADING_MAP[i] }
        rows.unshift headings.collect { |i| i.gsub(/\w/, '=') }
        rows.unshift headings
        print_table(rows, indent: 2)
      end
      puts
    end
  end
end
