require "thor"

class Translatomatic::CLI < Thor
  include Translatomatic::Util
  package_name "Translatomatic"
  map %W[-v --version] => :version
  map %W[-L --list] => :translators

  desc "translate file locale...", "translate files to target locales"
  method_option :translator, enum: Translatomatic::Translator.names
  method_option :source_locale, desc: "The locale of the source file, default is autodetermined"
  method_option :debug, type: :boolean, desc: "Turn on debugging output"
  Translatomatic::Converter.options.each do |option|
    method_option option.name, option.to_hash
  end
  Translatomatic::Database.options.each do |option|
    method_option option.name, option.to_hash
  end
  Translatomatic::Translator.modules.each do |mod|
    mod.options.each do |option|
      method_option option.name, option.to_hash
    end
  end
  def translate(file, *locales)
    begin
      log.info("dry run: files will not be translated or written") if options[:dry_run]
      Translatomatic::Config.instance.debug = options[:debug]
      Translatomatic::Database.new(options)
      converter = Translatomatic::Converter.new(options)
      source = Translatomatic::ResourceFile.load(file, options[:source_locale])
      raise "unsupported file type #{source_file}" unless source
      locales.each do |locale|
        converter.translate(source, locale)
      end
      log.info converter.stats
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

  desc 'version', 'Display version'
  def version
    puts "Translatomatic version #{Translatomatic::VERSION}"
  end
end
