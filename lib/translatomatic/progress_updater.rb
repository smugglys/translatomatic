module Translatomatic
  # implements Converter listener
  class ProgressUpdater
    # Create a new progress updater
    # @param progressbar [Progressbar] A ruby-progressbar object
    def initialize(progressbar)
      @progressbar = progressbar
    end

    # @param count [Number] The number of strings processed
    # @return [Number] The total number of processed strings
    def processed_strings(count)
      @progressbar.progress += count
    end

  end
end
