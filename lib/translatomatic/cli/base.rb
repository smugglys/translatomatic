require 'thor'

module Translatomatic::CLI
  # Base class for command line interface classes
  class Base < Thor

    private

    include Translatomatic::Util
    include Translatomatic::DefineOptions

    # creates thor options
    def self.thor_options(klass, object)
      Translatomatic::Option.options_from_object(object).each do |option|
        next if option.hidden
        klass.method_option option.name, option.to_thor
      end
    end

    def parse_list(list, default = [])
      # use the default list if the list is empty
      list = default if list.nil? || list.empty?
      list = [list] unless list.kind_of?(Array)
      # split list entries on ','
      list.collect { |i| i.split(/[, ]/) }.flatten.compact
    end

    # run the give code block, display exceptions.
    # return true if the code ran without exceptions
    def run
      begin
        yield
        true
      rescue Interrupt
        puts "\n" + t("cli.aborted")
        false
      rescue Exception => e
        finish_log
        log.error(e.message)
        log.debug(e.backtrace.join("\n"))
        raise e if ENV["TEST"] # reraise exceptions in test
        false
      end
    end

    def finish_log
      conf.logger.finish if conf.logger.respond_to?(:finish)
    end

    def conf
      Translatomatic::Config.instance
    end

    # get an option value
    # use options specified on the command line first.
    # falls back to configuration values.
    def cli_option(key)
      if options[key] && !empty_array?(options[key])
        options[key]
      else
        conf.get(key)
      end
    end

    def empty_array?(value)
      value.kind_of?(Array) && value.empty?
    end

  end
end
