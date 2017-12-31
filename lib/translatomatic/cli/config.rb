module Translatomatic::CLI
  # Configuration functions for the command line interface
  class Config < Base

    desc "set key value", t("cli.config.set")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # Change a configuration setting
    # @param key [String] configuration key
    # @param value [String] new value for the configuration
    # @return [String] the new value
    def set(key, value)
      conf.set(key, value)
    end

    desc "remove key", t("cli.config.remove")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # Remove a configuration setting
    # @param key [String] configuration key to remove
    # @return [void]
    def remove(key)
      conf.remove(key)
    end

    desc "list", t("cli.config.list")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # List current configuration settings
    def list
      puts t("cli.config.configuration")
      print_config_table(:key, :value)
    end

    desc "describe", t("cli.config.describe")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # Describe available configuration settings
    def describe
      puts t("cli.config.configuration")
      print_config_table(:key, :type, :desc)
    end

    private

    TABLE_HEADING_MAP = {
      key: t("cli.config.name"),
      type: t("cli.config.type"),
      value: t("cli.config.value"),
      desc: t("cli.config.desc"),
    }

    def print_config_table(*columns)
      puts
      rows = []
      rows << columns.collect { |i| TABLE_HEADING_MAP[i] }
      rows << rows[0].collect { |i| i.gsub(/\w/, '=') }
      Translatomatic::Config.options.each do |option|
        key = option.name.to_s
        data = []
        columns.each do |column|
          data << case column
          when :key
            key
          when :value
            value = conf.get(key)
            value.nil? ? "-" : value
          when :type
            t("config.types.#{option.type}")
          when :desc
            option.description
          end
        end
        rows << data
      end
      rows.sort_by { |i| i[0] }
      print_table(rows, indent: 2)
      puts
    end
  end
end
