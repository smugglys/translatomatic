module Translatomatic
  # implements Converter listener
  class ProgressUpdater
    # Create a new progress updater
    # @param progressbar [Progressbar] A ruby-progressbar object
    def initialize(progressbar)
      @progressbar = progressbar
    end

    # @param count [Number] The number of strings translated
    # @return [Number] The total number of translated strings
    def translated_texts(count)
      @progressbar.progress += count
    end

    # @param count [Number] The number of strings that couldn't be translated
    # @return [Number] the total number of untranslated strings
    def untranslated_texts(count)
      @progressbar.total -= count
    end
  end
end
