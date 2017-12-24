require 'singleton'
class Translatomatic::Config
  include Singleton

  attr_accessor :logger

  private

  def initialize
    @logger = Translatomatic::Logger.new
  end
end
