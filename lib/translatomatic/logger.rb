class Translatomatic::Logger
  attr_accessor :progressbar

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
  end

  def method_missing(name, *args)
    if @logger.respond_to?(name)
      @progressbar.clear if @progressbar
      @logger.send(name, *args)
      @progressbar.refresh(force: true) if @progressbar && !@progressbar.stopped?
    end
  end

  def finish
    @progressbar.finish if @progressbar
  end

end
