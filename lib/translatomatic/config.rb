require 'singleton'
class Translatomatic::Config
  include Singleton

  attr_accessor :logger
  attr_accessor :debug

  private

  def initialize
    @logger = Logger.new(STDOUT)
    @debug = ENV['DEBUG'] ? true : false
  end

  def debug?
    @debug
  end
end
