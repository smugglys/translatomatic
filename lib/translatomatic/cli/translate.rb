require 'ruby-progressbar'

# Command line interface to translatomatic
module Translatomatic::CLI
  # Translation functions for the command line interface
  class Translate < Base
    default_task :file

    define_options(
      { name: :translator, type: :array, aliases: '-t',
        desc: t('cli.translate.translator'),
        enum: Translatomatic::Translator.names },
      { name: :source_locale, desc: t('cli.source_locale') },
      { name: :share, desc: t('cli.share'), default: false },
      { name: :target_locales, desc: t('cli.target_locales'),
        type: :array },
      { name: :source_files, desc: t('cli.source_files'),
        type: :path_array }
    )

    desc 'string text locale...', t('cli.translate.string')
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

        puts format('(%s) %s', @source_locale, text)
        @translators.each do |translator|
          puts t('cli.using_translator', name: translator.name)
          @target_locales.each do |target_locale|
            result = translator.translate([text], @source_locale, target_locale)
            puts format('  -> (%s) %s', target_locale, result)
          end
          puts
        end

        finish_log
      end
    end

    desc 'file filename locale...', t('cli.translate.file')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    thor_options(self, Translatomatic::CLI::Translate)
    thor_options(self, Translatomatic::FileTranslator)
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
        source_files = parse_list(file, cli_option(:source_files))
        source_files.each do |path|
          raise t('file.not_found', file: path) unless File.exist?(path)
          source = Translatomatic::ResourceFile.load(path, @source_locale)
          raise t('file.unsupported', file: path) unless source
        end

        # set up database
        Translatomatic::Database.new(options)

        # set up file translatiln
        translation_count = calculate_translation_count(source_files, @target_locales)
        ft_options = options.merge(
          translator: @translators,
          listener: progress_updater(translation_count)
        )
        ft = Translatomatic::FileTranslator.new(ft_options)

        source_files.each do |path|
          # read source file
          source = Translatomatic::ResourceFile.load(path, @source_locale)

          # convert source to locale(s) and write files
          @target_locales.each do |i|
            to_locale = locale(i)
            next if to_locale.language == source.locale.language
            ft.translate_to_file(source, to_locale)
          end
        end

        log.info ft.stats
        finish_log

        share_translations(ft) if cli_option(:share)
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
      raise t('cli.locales_required') if @target_locales.empty?
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

    def share_translations(ft)
      return if ft.db_translations.empty?

      tmx = Translatomatic::TMX::Document.from_texts(ft.db_translations)
      available = Translatomatic::Translator.available(options)
      available.each do |translator|
        if translator.respond_to?(:upload)
          log.info(t('cli.uploading_tmx', name: translator.name))
          translator.upload(tmx)
        end
      end

      ActiveRecord::Base.transaction do
        ft.db_translations.each do |text|
          text.update(shared: true) if text.is_translated?
        end
      end
    end

    # create a progress bar and progress updater
    def progress_updater(translation_count)
      return nil unless cli_option(:wank)
      # set up progress bar
      progressbar = ProgressBar.create(
        title: t('cli.translating'),
        format: '%t: |%B| %E ',
        autofinish: false,
        total: translation_count
      )
      conf.logger.progressbar = progressbar
      Translatomatic::ProgressUpdater.new(progressbar)
    end
  end # class
end   # module
