require 'singleton'
class Translatomatic::Config
  include Singleton

  attr_accessor :logger
  attr_accessor :debug

  def debug=(value)
    @debug = value ? true : false
    @logger.level = @debug ? Logger::DEBUG : Logger::INFO
  end

  private

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
    self.debug = ENV['DEBUG'] ? true : false
  end

  def debug?
    @debug
  end
end
