require 'thor'

module Translatomatic
  module CLI
    # Base class for command line interface classes
    class Base < Thor
      private

      include Translatomatic::Util
      include Translatomatic::DefineOptions

      # creates thor options
      class << self
        private

        def thor_options(klass, object)
          Translatomatic::Option.options_from_object(object).each do |option|
            next if option.hidden
            name = option.name.to_s.dasherize
            klass.method_option name, option.to_thor
          end
        end
      end

      def parse_list(list, default = [])
        # use the default list if the list is empty
        list = default if list.nil? || list.empty?
        list = [list] unless list.is_a?(Array)
        # split list entries on ','
        list.compact.collect { |i| i.split(/[, ]/) }.flatten.compact
      end

      # run the give code block, display exceptions.
      # return true if the code ran without exceptions
      def run
        merge_options_and_config
        @dry_run = cli_option(:dry_run)
        conf.logger.level = ::Logger::DEBUG if cli_option(:debug)
        log.info(t('cli.dry_run')) if @dry_run

        yield
        true
      rescue Interrupt
        puts "\n" + t('cli.aborted')
        false
      rescue StandardError => e
        finish_log
        log.error(e.message)
        log.debug(e.backtrace.join("\n"))
        raise e if ENV['TEST'] # reraise exceptions in test
        false
      end

      def finish_log
        conf.logger.finish if conf.logger.respond_to?(:finish)
      end

      def conf
        Translatomatic.config
      end

      # get an option value
      def cli_option(key)
        @options[key]
      end

      # create @options from options and config
      def merge_options_and_config
        # start with command line options
        @options = options.transform_keys { |i| i.to_s.underscore.to_sym }
        # fill missing entries with config values
        settings = conf.all
        settings.each do |key, value|
          @options[key] = value unless @options.include?(key)
        end
      end

      def empty_array?(value)
        value.is_a?(Array) && value.empty?
      end

      def add_table_heading(rows, headings)
        underscores = headings.collect { |i| i.gsub(/\w/, '=') }
        [headings, underscores] + rows
      end
    end
  end
end
