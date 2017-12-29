require 'singleton'

# Translatomatic configuration
class Translatomatic::Config
  include Singleton

  # @return [Logger] The logger instance
  attr_accessor :logger

  private

  def initialize
    @logger = Translatomatic::Logger.new
  end
end
