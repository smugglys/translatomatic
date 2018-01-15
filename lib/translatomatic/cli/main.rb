# Command line interface to translatomatic
module Translatomatic::CLI
  # Main command line interface
  class Main < Base
    package_name 'Translatomatic'
    map %w[-v --version] => :version
    map %w[-L --list] => :translators

    desc 'translate', t('cli.translate.subcommand')
    subcommand 'translate', Translate

    desc 'database', t('cli.database.subcommand')
    subcommand 'database', Database

    desc 'config', t('cli.config.subcommand')
    subcommand 'config', Config

    desc 'display file [key...]', t('cli.display_values')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    method_option :target_locales, type: :string, desc: t('cli.locales_to_display')
    method_option :sentences, type: :boolean, desc: t('cli.display_sentences')
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
          locales.each do |locale|
            path = source.locale_path(locale)
            display_properties(path, keys) if path.exist?
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

    desc 'services', t('cli.list_backends')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # List available translator services
    # @return [void]
    def services
      run { puts Translatomatic::Translator.list }
    end

    desc 'version', t('cli.display_version')
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # Display version number
    # @return [void]
    def version
      puts "Translatomatic v#{Translatomatic::VERSION}"
    end

    private

    def display_properties(path, keys)
      resource = Translatomatic::ResourceFile.load(path)
      display_keys(resource, keys)
    end

    def display_keys(source, keys)
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
  end # class
end   # module
