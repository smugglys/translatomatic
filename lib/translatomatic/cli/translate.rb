require 'ruby-progressbar'

module Translatomatic
  module CLI
    # Translation functions for the command line interface
    class Translate < Base
      default_task :file

      define_option :translator, type: :array, aliases: '-t',
                                 desc: t('cli.translate.translator'),
                                 enum: Translatomatic::Translator.names
      define_option :source_locale, desc: t('cli.source_locale')
      define_option :share, desc: t('cli.share'), default: false
      define_option :target_locales, desc: t('cli.target_locales'),
                                     type: :array
      define_option :source_files, desc: t('cli.source_files'),
                                   type: :path_array

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

          template = '(%<locale>s) %<text>s'
          puts format(template, locale: @source_locale, text: text)
          @translators.each do |translator|
            puts t('cli.using_translator', name: translator.name)
            @target_locales.each do |l|
              value = translator.translate([text], @source_locale, l)
              puts format('  -> ' + template, locale: l, text: value)
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

          # set up file translation
          count = translation_count(source_files, @target_locales)
          ft_options = options.merge(
            translator: @translators,
            listener: progress_updater(count)
          )
          ft = Translatomatic::FileTranslator.new(ft_options)

          source_files.each do |path|
            # read source file
            source = Translatomatic::ResourceFile.load(path, @source_locale)

            # convert source to locale(s) and write files
            @target_locales.each do |i|
              to_locale = locale(i)
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
        log.debug("using source locale: #{@source_locale}")

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
        cli_option(:source_locale) || Translatomatic::Locale.default.to_s
      end

      def translation_count(source_files, locales)
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
            text.update(shared: true) if text.translated?
          end
        end
      end

      # create a progress bar and progress updater
      def progress_updater(count)
        return nil unless cli_option(:wank)
        # set up progress bar
        progressbar = ProgressBar.create(
          title: t('cli.translating'),
          format: '%t: |%B| %E ', # rubocop:disable Style/FormatStringToken
          autofinish: false,
          total: count
        )
        conf.logger.progressbar = progressbar
        Translatomatic::ProgressUpdater.new(progressbar)
      end
    end
  end
end
