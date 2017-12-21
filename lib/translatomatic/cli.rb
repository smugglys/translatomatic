require "thor"

class Translatomatic::CLI < Thor
  include Translatomatic::Util
  package_name "Translatomatic"
  map %W[-v --version] => :version

  desc "translate file locale...", "translate files to target locales"
  method_option :translator, enum: Translatomatic::Translator.names
  method_option :source_locale, desc: "The locale of the source file, default is autodetermined"
  Translatomatic::Translator.modules.each do |mod|
    mod.options.each do |option|
      method_option option.name, banner: option.description
    end
  end
  def translate(file, *locales)
    begin
      db = Translatomatic::Database.new(options)
      converter = Translatomatic::Converter.new(options)
      source = Translatomatic::ResourceFile.load(file, options[:source_locale])
      raise "unsupported file type #{source_file}" unless source
      locales.each do |locale|
        converter.translate(source, locale)
      end
    rescue Exception => e
      log.error("error translating #{file}")
      log.error(e.message)
      log.debug(e.backtrace.join("\n"))
    end
  end

  desc "autotranslate", "translates all translatable files"
  method_option :source_locale, desc: "The locale of the source files, default is autodetermined"
  method_option :locales, type: :array, desc:
  def autotranslate
    # Method:
    # - find all source resource files under current directory
    # - find existing translations corresponding to the source file to
    #   create a list of target locales, or prompt user for locales,
    #   or use locales from --locales option.
    # - TODO: how to determine which file to use as source?
    # - perform translations
    sources = Translatomatic::ResourceFile.find(Dir.pwd)
  end

  desc "translators", "list available translation backends"
  def translators
    puts Translatomatic::Translator.list
  end

  desc 'version', 'Display version'
  def version
    puts "Translatomatic version #{Translatomatic::VERSION}"
  end
end
