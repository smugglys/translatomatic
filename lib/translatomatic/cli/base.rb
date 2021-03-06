require 'thor'
require 'rainbow'

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
      def run
        Translatomatic.config = create_config
        @dry_run = conf.get(:dry_run)
        log.level = ::Logger::DEBUG if conf.get(:debug)
        log.info(t('cli.dry_run')) if @dry_run
        yield
      rescue Interrupt
        puts "\n" + t('cli.aborted')
      rescue StandardError => e
        handle_run_error(e)
      end

      def create_config
        Translatomatic::Config::Settings.new(runtime: options)
      end

      def handle_run_error(e)
        finish_log
        log.error(e.message)
        log.debug(e.backtrace.join("\n"))
        raise e if ENV['TEST'] # reraise exceptions in test
      end

      def finish_log
        log.finish if log.respond_to?(:finish)
      end

      def conf
        Translatomatic.config
      end

      def rainbow
        @rainbow ||= begin
          rainbow = Rainbow.new
          rainbow.enabled = !conf.get(:no_wank)
          rainbow
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
