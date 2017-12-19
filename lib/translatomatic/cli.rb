require "thor"

class Translatomatic::CLI < Thor

  desc "translate file", "translate text files"
  option :translator
  option :source_language
  def translate(file = nil)
    Translatomatic::Translation.new(options).translate(file)
  end

  desc "translators", "list available translation backends"
  def translators
    puts Translatomatic::Translator.modules
  end

end
