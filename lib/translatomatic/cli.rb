require "thor"

class Translatomatic::CLI < Thor
  include Translatomatic::Util

  desc "translate file locale...", "translate text files"
  method_option :translator, enum: Translatomatic::Translator.names
  method_option :source_locale
  Translatomatic::Translator.modules.each do |mod|
    mod.options.each do |option|
      method_option option.name, banner: option.description
    end
  end
  def translate(file, *locales)
    begin
      db = Translatomatic::Database.new(options)
      converter = Translatomatic::Converter.new(options)
      locales.each do |locale|
        converter.translate(file, locale)
      end
    rescue Exception => e
      log.error("error translating #{file}")
      log.error(e.message)
      log.debug(e.backtrace.join("\n"))
    end
  end

  desc "translators", "list available translation backends"
  def translators
    puts Translatomatic::Translator.list
  end

end
