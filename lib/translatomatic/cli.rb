require "thor"

class Translatomatic::CLI < Thor

  desc "translate file target_locale", "translate text files"
  method_option :translator, enum: Translatomatic::Translator.names
  method_option :source_locale
  Translatomatic::Translator.modules.each do |mod|
    mod.options.each do |option|
      method_option option.name, banner: option.description
    end
  end
  def translate(file, locale)
    Translatomatic::Translation.new(options).translate(file, locale)
  end

  desc "translators", "list available translation backends"
  def translators
    puts Translatomatic::Translator.list
  end

end
