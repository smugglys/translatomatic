class Translatomatic::Logger
  attr_reader :progressbar

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end

    @progressbar = ProgressBar.create({
      title: "Translating",
      format: PROGRESS_BAR_FORMAT,
      autostart: false
    })
  end

  def method_missing(name, *args)
    if @logger.respond_to?(name)
      showing_progress = @progressbar.started? && !@progressbar.finished?
      @progressbar.clear #if showing_progress
      @logger.send(name, *args)
      @progressbar.refresh if showing_progress
    end
  end

  private

  PROGRESS_BAR_FORMAT =  "%t: |%B| %E"
end
