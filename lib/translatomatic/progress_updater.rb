# implements Converter listener
class Translatomatic::ProgressUpdater
  # Create a new progress updater
  # @param progressbar [Progressbar] A ruby-progressbar object
  def initialize(progressbar)
    @progressbar = progressbar
  end

  # @return [Number] the number of translated strings
  def translated_texts(texts)
    @progressbar.progress += texts.length
  end

  # @return [Number] the number of untranslated strings
  def untranslated_texts(texts)
    @progressbar.total -= texts.length
  end
end
