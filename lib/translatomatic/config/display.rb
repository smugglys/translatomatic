module Translatomatic
  module Config
    # Methods for displaying configuration
    class Display
      attr_reader :options

      def initialize(opts = {})
        @options = opts
        @config_params = opts[:config_params]
        raise t('config.one_at_a_time') if opts[:user] && opts[:project]
      end

      # @return [Array<Array<String>>] Configuration table
      def config_table_body
        columns = options[:columns] || []
        rows = config_table_rows(columns)
        if rows.present?
          headings = columns.collect { |i| CONFIG_HEADING_MAP[i] }
          rows = add_table_heading(rows, headings)
        end
        rows
      end

      private

      include Translatomatic::Util

      CONFIG_HEADING_MAP = {
        key: t('config.heading.name'),
        type: t('config.heading.type'),
        value: t('config.heading.value'),
        desc: t('config.heading.desc')
      }.freeze

      CONFIG_VALUE_MAP = {
        key: :name,
        type: :type_name,
        desc: :description
      }.freeze

      def display_option?(option)
        key = option.name.to_s
        have_conf = Translatomatic.config.include?(key, @options)
        return false if option.command_line_only
        return false if options[:skip_blanks] && !have_conf
        true
      end

      def add_table_heading(rows, headings)
        underscores = headings.collect { |i| i.gsub(/\w/, '=') }
        [headings, underscores] + rows
      end

      def config_table_rows(columns)
        opts = Options.options.values.select { |i| display_option?(i) }
        rows = opts.collect { |i| option_to_table_row(i, columns) }
        rows.sort_by { |i| i[0] }
        rows
      end

      def option_to_table_row(option, columns)
        columns.collect { |i| config_table_column_value(option, i) }
      end

      def option_value(option)
        value = Translatomatic.config.get(option.name, @options)
        value.nil? ? '-' : value
      end

      def config_table_column_value(option, column)
        return option_value(option) if column == :value
        value_method = CONFIG_VALUE_MAP[column]
        return option.send(value_method).to_s if value_method
        raise "unhandled column type: #{column}"
      end
    end
  end
end
