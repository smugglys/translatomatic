require "thor"

class Translatomatic::CLI < Thor
  include Translatomatic::Util

  package_name "Translatomatic"
  map %W[-v --version] => :version
  map %W[-L --list] => :translators

  desc "translate file locale...", "Translate files to target locales"
  method_option :translator, enum: Translatomatic::Translator.names
  method_option :source_locale, desc: "The locale of the source file"
  method_option :debug, type: :boolean, desc: "Enable debugging output"
  method_option :wank, type: :boolean, default: true, desc: "Enable Progress bar"
  method_option :share, type: :boolean, default: false, desc:
    "Share translations with translators that support upload"
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
    run do
      log.info("Dry run: files will not be translated or written") if options[:dry_run]
      raise "One or more locales required" if locales.empty?

      config.logger.level = Logger::DEBUG if options[:debug]

      # load source file
      raise "File not found: #{file}" unless File.exist?(file)
      source = Translatomatic::ResourceFile.load(file, options[:source_locale])
      raise "Unsupported file type #{file}" unless source

      # set up database
      Translatomatic::Database.new(options)

      # select translator
      translator = select_translator(options)
      log.info("Using translator #{translator.name}")
      log.debug("Locales: #{locales}, Properties: #{source.properties.length}")

      # set up converter
      translation_count = source.properties.length * locales.length
      converter_options = options.merge(
        translator: translator, listener: progress_updater(translation_count)
      )
      converter = Translatomatic::Converter.new(converter_options)

      # convert source to locale(s)
      locales.each { |i| converter.translate(source, i) }

      log.info converter.stats
      config.logger.finish

      share_translations(converter) if options[:share]
    end
  end

  desc "display file [key...]", "Display values from a resource bundle"
  method_option :locales, type: :string, desc: "Locales to display"
  def display(file, *keys)
    run do
      source = Translatomatic::ResourceFile.load(file)
      keys = source.properties.keys if keys.empty?
      display_keys(source, keys)

      locales = (options[:locales] || "").split(',').flatten.compact
      locales << Translatomatic::Locale.default.to_s if locales.empty?

      # TODO: if locales not specified, determine the list of locales from
      # all the files in the resource bundle.
      unless locales.empty?
        locales.each do |locale|
          next if source.locale == locale
          path = source.locale_path(locale)
          if path.exist?
            resource = Translatomatic::ResourceFile.load(path)
            display_keys(resource, keys)
          end
        end
      else
      end
    end
  end

  desc "strings file [file...]", "Extract strings from files"
  def strings(*files)
    run do
      strings = []
      files.each do |file|
        extractor = Translatomatic::Extractor::Base.new(file)
        strings << extractor.extract
      end
      puts strings.join("\n")
    end
  end

  desc "list", "List available translation backends"
  def list
    run { puts Translatomatic::Translator.list }
  end

  desc 'version', 'Display version'
  def version
    puts "Translatomatic version #{Translatomatic::VERSION}"
  end

  private

  def share_translations(converter)
    return if converter.db_translations.empty?

    tmx = Translatomatic::TMX::Document.from_texts(converter.db_translations)
    available = Translatomatic::Translator.available(options)
    available.each do |translator|
      if translator.respond_to?(:upload)
        log.debug("Uploading tmx to #{translator.name}")
        translator.upload(tmx)
      end
    end

    ActiveModel::Base.transaction do
      converter.db_translations.each do |text|
        text.update(shared: true) if text.is_translated?
      end
    end
  end

  # create a progress bar and progress updater
  def progress_updater(translation_count)
    return nil unless options[:wank]
    # set up progress bar
    progressbar = ProgressBar.create(
      title: "Translating",
      format: "%t: |%B| %E ",
      autofinish: false,
      total: translation_count
    )
    config.logger.progressbar = progressbar
    Translatomatic::ProgressUpdater.new(progressbar)
  end

  # run the give code block, display exceptions.
  # return true if the code ran without exceptions
  def run
    begin
      yield
      true
    rescue Interrupt
      puts "\nAborted"
      false
    rescue Exception => e
      log.error(e.message)
      log.debug(e.backtrace.join("\n"))
      false
    end
  end

  def display_keys(source, keys)
    puts "File: #{source}"
    keys.each { |key| puts "#{key}: #{source.get(key)}" }
    puts
  end

  def config
    Translatomatic::Config.instance
  end

  def select_translator(options)
    # use options translator if specified
    if options[:translator]
      klass = Translatomatic::Translator.find(options[:translator])
      return klass.new(options)
    end

    # find all available translators that work with the given options
    available = Translatomatic::Translator.available(options)
    if available.empty?
      raise "No translators configured. Use the translators command to see options"
    end

    return available[0] if available.length == 1

    # prompt user for which translator to use
    say("Multiple translators available:")
    available.each_with_index { |mod, i| say(" #{i + 1}) #{mod.name}") }
    loop do
      idx = ask("Select translator (1-#{available.length}): ")
      idx = idx.to_i
      return available[idx - 1] if (1..available.length).include?(idx)
    end
  end
end
