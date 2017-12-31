# Command line interface to translatomatic
module Translatomatic::CLI
  # Translation functions for the command line interface
  class Translate < Base

    desc "string text locale...", t("cli.translate.string")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Translate)
    thor_options(self, Translatomatic::Translator.modules)
    # Translate a string to target locales
    # @param text [String] String to translate
    # @param locales [Array<String>] List of target locales
    # @return [void]
    def string(text, *locales)
      run do
        setup_translation(locales)

        puts "(%s) %s" % [@source_locale, text]
        @target_locales.each do |target_locale|
          result = @translator.translate([text], @source_locale, target_locale)
          puts "  -> (%s) %s" % [target_locale, result]
        end

        finish_log
      end
    end

    desc "file filename locale...", t("cli.translate.file")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Translate)
    thor_options(self, Translatomatic::Converter)
    thor_options(self, Translatomatic::Database)
    thor_options(self, Translatomatic::Translator.modules)
    # Translate files to target locales
    # @param file [String] Resource file to translate
    # @param locales [Array<String>] List of target locales
    # @return [void]
    def file(file, *locales)
      run do
        setup_translation(locales)

        # load source file
        raise t("cli.file_not_found", file: file) unless File.exist?(file)
        source = Translatomatic::ResourceFile.load(file, @source_locale)
        raise t("cli.file_unsupported", file: file) unless source

        # set up database
        Translatomatic::Database.new(options)

        log.debug(t("cli.locales_properties", locales: locales, properties: source.properties.length))

        # set up converter
        translation_count = calculate_translation_count(source, @target_locales)
        converter_options = options.merge(
          translator: @translator,
          listener: progress_updater(translation_count)
        )
        converter = Translatomatic::Converter.new(converter_options)

        # convert source to locale(s) and write files
        @target_locales.each { |i| converter.translate_to_file(source, i) }

        log.info converter.stats
        finish_log

        share_translations(converter) if cli_option(:share)
      end
    end

    private

    define_options(
      { name: :source_locale, desc: t("cli.source_locale") },
      { name: :share, desc: t("cli.share"), default: false },
      { name: :target_locales, desc: t("cli.target_locales"),
        type: :array, hidden: true },
    )

    def setup_translation(locales)
      log.info(t("cli.dry_run")) if cli_option(:dry_run)

      @target_locales = parse_list(locales, cli_option(:target_locales))
      @source_locale = determine_source_locale
      raise t("cli.locales_required") if @target_locales.empty?
      conf.logger.level = Logger::DEBUG if cli_option(:debug)

      # select translator
      @translator = select_translator
      log.info(t("cli.using_translator", name: @translator.name))
    end

    def determine_source_locale
      cli_option(:source_locale) || conf.default_locale
    end

    def calculate_translation_count(source, locales)
      source.sentences.length * locales.length
    end

    def share_translations(converter)
      return if converter.db_translations.empty?

      tmx = Translatomatic::TMX::Document.from_texts(converter.db_translations)
      available = Translatomatic::Translator.available(options)
      available.each do |translator|
        if translator.respond_to?(:upload)
          log.info(t("cli.uploading_tmx", name: translator.name))
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
      return nil unless cli_option(:wank)
      # set up progress bar
      progressbar = ProgressBar.create(
        title: t("cli.translating"),
        format: "%t: |%B| %E ",
        autofinish: false,
        total: translation_count
      )
      conf.logger.progressbar = progressbar
      Translatomatic::ProgressUpdater.new(progressbar)
    end

    def select_translator
      # use options translator if specified
      if cli_option(:translator)
        klass = Translatomatic::Translator.find(cli_option(:translator))
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

  end # class
end   # module
