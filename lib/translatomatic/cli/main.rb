# Command line interface to translatomatic
module Translatomatic
  module CLI
    # Main command line interface
    class Main < Base
      package_name 'Translatomatic'
      map %w[-v --version] => :version
      map %w[-L --list] => :providers

      desc 'translate', t('cli.translate.subcommand')
      subcommand 'translate', Translate

      desc 'database', t('cli.database.subcommand')
      subcommand 'database', Database

      desc 'config', t('cli.config.subcommand')
      subcommand 'config', Config

      desc 'display file [key...]', t('cli.display_values')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      method_option :target_locales, type: :string,
                                     desc: t('cli.locales_to_display')
      method_option :sentences, type: :boolean,
                                desc: t('cli.display_sentences')
      # Display values from a resource bundle
      # @param file [String] Path to resource file
      # @param keys [Array<String>] Optional list of locales
      # @return [void]
      def display(file = nil, *keys)
        run do
          locales = cli_option(:target_locales)
          source_files = parse_list(file, cli_option(:source_files))
          source_files.each do |path|
            raise t('file.not_found', file: path) unless File.exist?(path)
            source = Translatomatic::ResourceFile.load(path)
            display_properties(source, keys)
            locales.each do |locale|
              path = source.locale_path(locale)
              next if path == source.path || !path.exist?
              resource = Translatomatic::ResourceFile.load(path)
              display_properties(resource, keys)
            end
          end
        end
      end

      desc 'strings file [file...]', t('cli.extract_strings')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      # Extract strings from non-resource files
      # @param files [Array<String>] List of paths to files
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

      desc 'convert source target', t('cli.convert')
      # Convert a resource file from one format to another
      # @param source [String] An existing resource file
      # @param target [String] The name of a target resource file
      # @return [void]
      def convert(source, target)
        run do
          converter = Translatomatic::Converter.new
          converter.convert(source, target)
        end
      end

      desc 'providers', t('cli.providers')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      # List available translation providers
      # @return [void]
      def providers
        run { display_providers }
      end

      desc 'version', t('cli.display_version')
      thor_options(self, Translatomatic::CLI::CommonOptions)
      # Display version number
      # @return [void]
      def version
        puts "Translatomatic v#{Translatomatic::VERSION}"
      end

      private

      # @return [String] A description of all providers and options
      def display_providers
        puts t('provider.options') + "\n\n"
        display_provider_options
        puts

        puts t('provider.status') + "\n\n"
        display_provider_status
        puts
      end

      def display_provider_options
        rows = []
        Translatomatic::Provider.types.each do |klass|
          rows += provider_option_rows(klass)
        end
        headers = %i[name option description env]
        heading = headers.collect { |i| t("cli.provider.#{i}") }
        print_table(add_table_heading(rows, heading), indent: 2)
      end

      def provider_option_rows(klass)
        name = klass.name.demodulize
        opts = klass.options || []
        opts.collect { |i| provider_option_row(name, i) }
      end

      def provider_option_row(name, opt)
        args = []
        args << name
        args << '--' + opt.name.to_s.tr('_', '-')
        args << opt.description
        args << opt.env_name ? "ENV[#{opt.env_name}]" : ''
        args
      end

      def display_provider_status
        types = Translatomatic::Provider.types
        available = available_providers
        rows = types.sort_by { |i| available[i.name] ? 0 : 1 }.map do |klass|
          provider_status_row(klass, available)
        end
        headers = %i[name available]
        heading = headers.collect { |i| t("cli.provider.#{i}") }
        print_table(add_table_heading(rows, heading), indent: 2)
      end

      def available_providers
        config_all = Translatomatic.config.all
        available = {}
        configured = Translatomatic::Provider.available(config_all)
        configured.each { |i| available[i.class.name] = true }
        available
      end

      def provider_status_row(klass, available)
        name = klass.name.demodulize
        avail = available[klass.name] ? 'yes' : 'no'
        args = []
        args << name
        args << t('cli.provider.available_' + avail)
        args << Translatomatic::Provider.get_error(name)
        args
      end

      def display_properties(source, keys)
        puts t('cli.file_source', file: source)
        rows = []
        keys = source.properties.keys if keys.empty?
        keys.each do |key|
          value = source.get(key)
          rows << [key + ':', value]
        end
        print_table(rows, indent: 2)

        if options[:sentences]
          puts t('cli.sentences')
          source.sentences.each do |sentence|
            puts '- ' + sentence.to_s
          end
        end

        puts
      end
    end
  end
end
