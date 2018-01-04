# Command line interface to translatomatic
module Translatomatic::CLI
  # Translation functions for the command line interface
  class Translate < Base

    default_task :file
    
    define_options(
      { name: :translator, type: :array, aliases: "-t",
        desc: t("converter.translator"),
        enum: Translatomatic::Translator.names
      },
      { name: :source_locale, desc: t("cli.source_locale") },
      { name: :share, desc: t("cli.share"), default: false },
      { name: :target_locales, desc: t("cli.target_locales"),
        type: :array
      },
      { name: :source_files, desc: t("cli.source_files"),
        type: :array
      },
      )

    desc "string text locale...", t("cli.translate.string")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Translate)
    thor_options(self, Translatomatic::Translator.modules)
    # Translate a string to target locales
    # @param text [String] String to translate
    # @param locales [Array<String>] List of target locales, can also be set
    #   with the --target-locales option
    # @return [void]
    def string(text, *locales)
      run do
        setup_translation
        determine_target_locales(locales)

        puts "(%s) %s" % [@source_locale, text]
        @translators.each do |translator|
          puts t("cli.using_translator", name: translator.name)
          @target_locales.each do |target_locale|
            result = translator.translate([text], @source_locale, target_locale)
            puts "  -> (%s) %s" % [target_locale, result]
          end
          puts
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
    # @param file [String] Resource file to translate, can also be set
    #   with the --source-files option.
    # @param locales [Array<String>] List of target locales, can also be set
    #   with the --target-locales option
    # @return [void]
    def file(file = nil, *locales)
      run do
        setup_translation
        determine_target_locales(locales)

        # check source file(s) exist and they can be loaded
        source_files = parse_list(cli_option(:source_files), file)
        source_files.each do |file|
          file = source_path(file)
          raise t("cli.file_not_found", file: file) unless File.exist?(file)
          source = Translatomatic::ResourceFile.load(file, @source_locale)
          raise t("cli.file_unsupported", file: file) unless source
        end

        # set up database
        Translatomatic::Database.new(options)

        # set up converter
        translation_count = calculate_translation_count(source_files, @target_locales)
        converter_options = options.merge(
          translator: @translators,
          listener: progress_updater(translation_count)
        )
        converter = Translatomatic::Converter.new(converter_options)

        source_files.each do |file|
          # read source file
          source = Translatomatic::ResourceFile.load(file, @source_locale)

          # convert source to locale(s) and write files
          @target_locales.each do |i|
            to_locale = locale(i)
            next if to_locale.language == source.locale.language
            converter.translate_to_file(source, to_locale)
          end
        end

        log.info converter.stats
        finish_log

        share_translations(converter) if cli_option(:share)
      end
    end

    private

    def setup_translation
      @source_locale = determine_source_locale
      # resolve translators
      @translators = Translatomatic::Translator.resolve(
        cli_option(:translator), options
      )
    end

    def determine_target_locales(locales)
      @target_locales = parse_list(locales, cli_option(:target_locales))
      raise t("cli.locales_required") if @target_locales.empty?
    end

    def determine_source_locale
      cli_option(:source_locale) || conf.default_locale
    end

    def calculate_translation_count(source_files, locales)
      count = 0
      source_files.each do |file|
        source = Translatomatic::ResourceFile.load(file, @source_locale)
        count += source.sentences.length * locales.length
      end
      count
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

    # convert the given path to an absolute path if necessary, relative
    # to project root.
    def source_path(path)
      if path.start_with?("~/")
        # replace ~/ with home directory
        path = path.sub(/\A~\//, Dir.home + "/")
      end
      File.absolute_path(path, conf.project_path)
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

  end # class
end   # module
