module Translatomatic
  # Class to update the progress bar for the CLI
  class ProgressUpdater
    # Create a new progress updater
    # @param progressbar [Progressbar] A ruby-progressbar object
    def initialize(progressbar)
      @progressbar = progressbar
    end

    # @param count [Number] Update progress
    # @return [Number] The total number of processed items.
    def update_progress(count)
      @progressbar.progress += count
    end
  end
end
