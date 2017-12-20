require 'singleton'
class Translatomatic::Config
  include Singleton

  attr_accessor :logger
  attr_accessor :debug

  private

  def initialize
    @debug = ENV['DEBUG'] ? true : false
    @logger = Logger.new(STDOUT)
    @logger.level = @debug ? Logger::DEBUG : Logger::INFO
    @logger.formatter = proc do |severity, datetime, progname, msg|
      date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
      "[#{date_format}] #{severity.ljust(5)}: #{msg}\n"
    end
  end

  def debug?
    @debug
  end
end
