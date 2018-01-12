require 'logger'

module Translatomatic
  # Logging
  class Logger
    # @return [ProgressBar] A progress bar
    attr_accessor :progressbar

    # @return [Translatomatic::Logger] create a new logger instance
    def initialize
      @logger = ::Logger.new(STDOUT)
      @logger.level = ENV['DEBUG'] ? ::Logger::DEBUG : ::Logger::INFO
      @logger.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end
    end

    # Called at the end of translatomatic to clear the progress bar.
    def finish
      @finished ||= begin
        @progressbar.finish if @progressbar
        true
      end
    end

    private

    def respond_to_missing?(name, include_private = false)
      @logger.respond_to?(name) || super
    end

    def method_missing(name, *args)
      if @logger.respond_to?(name)
        handle_logger_method(name, args)
      else
        super
      end
    end

    def handle_logger_method(name, args)
      @progressbar.clear if @progressbar
      @logger.send(name, *args)
      refresh_progress_bar
    end

    def refresh_progress_bar
      return unless @progressbar && !@progressbar.stopped?
      @progressbar.refresh(force: true)
    end
  end
end
