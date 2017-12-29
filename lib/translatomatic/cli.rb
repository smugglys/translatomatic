require "thor"

# Command line interface to translatomatic
class Translatomatic::CLI < Thor
  include Translatomatic::Util

  begin
    config = Translatomatic::Config.instance
    I18n.default_locale = config.default_locale
  end

  package_name "Translatomatic"
  map %W[-v --version] => :version
  map %W[-L --list] => :translators

  desc "translate file locale...", t("cli.translate")
  method_option :translator, enum: Translatomatic::Translator.names
  method_option :source_locale, desc: t("cli.source_locale")
  method_option :debug, type: :boolean, desc: t("cli.debug")
  method_option :wank, type: :boolean, default: true, desc: t("cli.wank")
  method_option :share, type: :boolean, default: false, desc: t("cli.share")
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
  # Translate files to target locales
  # @param [String] file Resource file to translate
  # @param [Array<String>] locales List of target locales
  # @return [void]
  def translate(file, *locales)
    run do
      log.info(t("cli.dry_run")) if options[:dry_run]
      raise t("cli.locales_required") if locales.empty?

      config.logger.level = Logger::DEBUG if options[:debug]

      # load source file
      raise t("cli.file_not_found", file: file) unless File.exist?(file)
      source = Translatomatic::ResourceFile.load(file, options[:source_locale])
      raise t("cli.file_unsupported", file: file) unless source

      # set up database
      Translatomatic::Database.new(options)

      # select translator
      translator = select_translator(options)
      log.info(t("cli.using_translator", name: translator.name))
      log.debug(t("cli.locales_properties",
        locales: locales, properties: source.properties.length))

      # set up converter
      translation_count = calculate_translation_count(source, locales)
      converter_options = options.merge(
        translator: translator, listener: progress_updater(translation_count)
      )
      converter = Translatomatic::Converter.new(converter_options)

      # convert source to locale(s) and write files
      locales.each { |i| converter.translate_to_file(source, i) }

      log.info converter.stats
      config.logger.finish

      share_translations(converter) if options[:share]
    end
  end

  desc "display file [key...]", t("cli.display_values")
  method_option :locales, type: :string, desc: t("cli.locales_to_display")
  method_option :sentences, type: :boolean, desc: t("cli.display_sentences")
  # Display values from a resource bundle
  # @param [String] file Path to resource file
  # @param [Array<String>] keys Optional list of locales
  # @return [void]
  def display(file, *keys)
    run do
      source = Translatomatic::ResourceFile.load(file)
      keys = source.properties.keys if keys.empty?
      display_keys(source, keys)

      # TODO: if locales not specified, determine the list of locales from
      # all the files in the resource bundle.
      locales = (options[:locales] || "").split(',').flatten.compact
      locales << Translatomatic::Locale.default.to_s if locales.empty?
      locales.each do |locale|
        display_properties(source, locale)
      end
    end
  end

  desc "strings file [file...]", t("cli.extract_strings")
  # Extract strings from non-resource files
  # @param [Array<String>] files List of paths to files
  # @return [void]
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

  desc "list", t("cli.list_backends")
  # List available translator services
  # @return [void]
  def list
    run { puts Translatomatic::Translator.list }
  end

  desc 'version', t("cli.display_version")
  # Display version number
  # @return [void]
  def version
    puts "Translatomatic v#{Translatomatic::VERSION}"
  end

  private

  def calculate_translation_count(source, locales)
    source.sentences.length * locales.length
  end

  def share_translations(converter)
    return if converter.db_translations.empty?

    tmx = Translatomatic::TMX::Document.from_texts(converter.db_translations)
    available = Translatomatic::Translator.available(options)
    available.each do |translator|
      if translator.respond_to?(:upload)
        log.debug(t("cli.uploading_tmx", name: translator.name))
        translator.upload(tmx)
      end
    end

    ActiveRecord::Base.transaction do
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
      title: t("cli.translating"),
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
      puts "\n" + t("cli.aborted")
      false
    rescue Exception => e
      config.logger.finish
      log.error(e.message)
      log.debug(e.backtrace.join("\n"))
      false
    end
  end

  def display_properties(source, locale)
    path = source.locale_path(locale)
    if path.exist?
      resource = Translatomatic::ResourceFile.load(path)
      display_keys(resource, keys)
    end
  end

  def display_keys(source, keys)
    puts t("cli.file_source", source)
    table = []
    keys.each do |key|
      value = source.get(key)
      table << [key + ":", value]
    end
    print_table(table, indent: 2)

    if options[:sentences]
      puts t("cli.sentences")
      source.sentences.each do |sentence|
        puts "- " + sentence.to_s
      end
    end

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
      raise t("cli.no_translators")
    end

    return available[0] if available.length == 1

    # prompt user for which translator to use
    say(t("cli.multiple_translators"))
    available.each_with_index { |mod, i| say(" #{i + 1}) #{mod.name}") }
    loop do
      idx = ask(t("cli.select_translator", available: available.length))
      idx = idx.to_i
      return available[idx - 1] if (1..available.length).include?(idx)
    end
  end

end
