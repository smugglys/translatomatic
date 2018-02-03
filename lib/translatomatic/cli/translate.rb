require 'ruby-progressbar'

module Translatomatic
  module CLI
    # Translation functions for the command line interface
    class Translate < Base
      default_task :file

      define_option :provider, type: :array, aliases: '-t',
                               desc: t('cli.translate.provider'),
                               enum: Translatomatic::Provider.names
      define_option :source_locale, desc: t('cli.source_locale')
      define_option :target_locales, desc: t('cli.target_locales'),
                                     type: :array
      define_option :source_files, desc: t('cli.source_files'),
                                   type: :path_array
      define_option :share, desc: t('cli.translate.share'), default: false

      desc 'string text locale...', t('cli.translate.string')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      thor_options(self, Translatomatic::CLI::Translate)
      thor_options(self, Translatomatic::Provider.types)
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
          @providers.each do |provider|
            puts t('cli.translate.using_provider', name: provider.name)
            @target_locales.each do |l|
              translations = provider.translate([text], @source_locale, l)
              translations.each do |translation|
                puts format('  -> ' + template, locale: l, text: translation)
              end
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
      thor_options(self, Translatomatic::Provider.types)
      thor_options(self, Translatomatic::ResourceFile.types)
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
          source_files = []
          files = parse_list(file, cli_option(:source_files))
          files.each do |path|
            raise t('file.not_found', file: path) unless File.exist?(path)
            source = resource_file(path)
            raise t('file.unsupported', file: path) unless source
            source_files << source
          end

          provider_names = @providers.collect(&:name)
          log.info(t('cli.translate.using_providers', list: provider_names))

          # set up database
          Translatomatic::Database.new(options)

          # set up file translation
          ft_options = options.merge(
            provider: @providers,
            listener: progress_updater
          )
          ft = Translatomatic::FileTranslator.new(ft_options)
          ft.translate_to_files(source_files, @target_locales)
          log.info ft.translator.stats
          finish_log
        end
      end

      private

      def resource_file(path, locale = @source_locale)
        file_opts = @options.merge(locale: locale)
        Translatomatic::ResourceFile.load(path, file_opts)
      end

      def setup_translation
        @source_locale = determine_source_locale
        log.debug("using source locale: #{@source_locale}")

        # resolve providers
        @providers = Translatomatic::Provider.resolve(
          cli_option(:provider), options
        )
        raise t('cli.translate.no_providers') if @providers.empty?
      end

      def determine_target_locales(locales)
        @target_locales = parse_list(locales, cli_option(:target_locales))
        raise t('cli.locales_required') if @target_locales.empty?
      end

      def determine_source_locale
        cli_option(:source_locale) || Translatomatic::Locale.default.to_s
      end

      # create a progress bar and progress updater
      def progress_updater
        return nil if cli_option(:no_wank)
        # set up progress bar
        progressbar = ProgressBar.create(
          title: t('cli.translate.translating'),
          format: '%t: |%B| %p%% ',
          autofinish: false
        )
        log.progressbar = progressbar if log.respond_to?(:progressbar=)
        Translatomatic::ProgressUpdater.new(progressbar)
      end
    end
  end
end
