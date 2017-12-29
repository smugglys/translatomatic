require 'singleton'

# Translatomatic configuration
class Translatomatic::Config
  include Singleton

  # @return [Logger] The logger instance
  attr_accessor :logger

  # @return [String] The default locale
  attr_accessor :default_locale

  private

  def initialize
    @logger = Translatomatic::Logger.new
    lang = (ENV['LANG'] || '').split(/\./)[0]
    @default_locale = Translatomatic::Locale.parse(lang).language || :en
  end
end
