require "thor"

class Translatomatic::CLI < Thor
  include Translatomatic::Util
  package_name "Translatomatic"
  map %W[-v --version] => :version
  map %W[-L --list] => :translators

  desc "translate file locale...", "translate files to target locale(s)"
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
  def translate(file, locale, *locales)
    begin
      log.info("dry run: files will not be translated or written") if options[:dry_run]

      Translatomatic::Config.instance.debug = options[:debug] if options[:debug]
      Translatomatic::Database.new(options)

      translator = options[:translator]
      unless options[:translator]
        # find a translator
        available = Translatomatic::Translator.available(options)
        translator = select_translator(available)
      end
      log.debug("using translator #{translator}")

      converter_options = options.merge(translator: translator)
      converter = Translatomatic::Converter.new(converter_options)
      source = Translatomatic::ResourceFile.load(file, options[:source_locale])

      raise "unsupported file type #{file}" unless source
      target_locales = [locale]
      target_locales += locales
      target_locales.each { |i| converter.translate(source, i) }

      log.info converter.stats
      true
    rescue Interrupt
      puts "\nAborted"
      false
    rescue Exception => e
      log.error("error translating #{file}")
      log.error(e.message)
      log.debug(e.backtrace.join("\n"))
      false
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

  private

  def select_translator(available)
    if available.empty?
      raise "No translators configured. Use the translators command to see options"
    end
    return available[0] if available.length == 1
    say("Multiple translators available:")
    available.each_with_index { |mod, i| say(" #{i + 1}) #{mod.name}") }
    loop do
      idx = ask("Select translator (1-#{available.length}): ")
      idx = idx.to_i
      return available[idx - 1] if (1..available.length).include?(idx)
    end
  end
end
