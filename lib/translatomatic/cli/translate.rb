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
          all_conf = conf.all
          source_locale = conf.get(:source_locale) || Locale.default.to_s
          target_locales = determine_target_locales(locales)
          providers = Provider.resolve(conf.get(:provider), all_conf)

          template = '(%<locale>s) %<text>s'
          puts format(template, locale: source_locale, text: text)
          providers.each do |provider|
            puts t('cli.translate.using_provider', name: provider.name)
            target_locales.each do |l|
              translations = provider.translate([text], source_locale, l)
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
          # set up database and progress updater
          Translatomatic::Database.new(conf.all)
          stats = Translation::Stats.new

          # translate the files
          source_files = load_source_files(file)
          listener = progress_updater(source_files, locales)
          source_files.each do |source|
            stats += translate_file(source, locales, listener)
          end
          log.info stats
          finish_log
        end
      end

      private

      def translate_file(source, locales, listener)
        file_opts = conf.all(for_file: source.path)
        target_locales = determine_target_locales(locales, source)
        ft_options = file_opts.merge(listener: listener)
        ft = Translatomatic::FileTranslator.new(ft_options)
        stats = Translation::Stats.new

        target_locales.each do |target_locale|
          log.info(t('cli.translate.translating_file',
                     source: source, source_locale: source.locale,
                     target_locale: target_locale))
          ft.translate_to_file(source, target_locale)
          stats += ft.translator.stats
        end
        stats
      end

      # load the source file(s)
      def load_source_files(file)
        source_files = []
        files = parse_list(file, conf.get(:source_files))
        files.each do |path|
          raise t('file.not_found', file: path) unless File.exist?(path)
          source = resource_file(path)
          raise t('file.unsupported', file: path) unless source
          source_files << source
        end
        source_files
      end

      def resource_file(path)
        Translatomatic::ResourceFile.load(path, conf.all(for_file: path))
      end

      # use list given on command line in preference to configuration
      def determine_target_locales(locales, source = nil)
        source_path = source ? source.path : nil
        config_locales = conf.get(:target_locales, for_file: source_path)
        target_locales = parse_list(locales, config_locales)
        raise t('cli.locales_required') if target_locales.empty?
        target_locales
      end

      def total_translations(source_files, locales)
        total = 0
        source_files.each do |source|
          property_values = source.properties.values
          texts = property_values.collect { |i| build_text(i, source.locale) }
          providers = resolve_providers(source).length
          to_locales = determine_target_locales(locales, source).length
          total += TextCollection.new(texts).count * providers * to_locales
        end
        total
      end

      def resolve_providers(source)
        Provider.resolve(conf.get(:provider, for_file: source.path), conf.all)
      end

      # create a progress bar and progress updater
      def progress_updater(source_files, locales)
        return nil if conf.get(:no_wank)
        # set up progress bar
        progressbar = ProgressBar.create(
          title: t('cli.translate.translating'),
          format: '%t: |%B| %p%% ',
          autofinish: false,
          total: total_translations(source_files, locales)
        )
        log.progressbar = progressbar if log.respond_to?(:progressbar=)
        Translatomatic::ProgressUpdater.new(progressbar)
      end
    end
  end
end
