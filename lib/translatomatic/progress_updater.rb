# implements Converter listener
class Translatomatic::ProgressUpdater
  def initialize(progressbar)
    @progressbar = progressbar
  end

  def translated_texts(texts)
    @progressbar.progress += texts.length
  end

  def untranslated_texts(texts)
    @progressbar.total -= texts.length
  end

end
