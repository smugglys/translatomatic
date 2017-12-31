# Command line interface to translatomatic
module Translatomatic::CLI
  # Main command line interface
  class Main < Base

    begin
      config = Translatomatic::Config.instance
      I18n.default_locale = config.default_locale
    end

    package_name "Translatomatic"
    map %W[-v --version] => :version
    map %W[-L --list] => :translators

    desc "translate", t("cli.translate.subcommand")
    subcommand "translate", Translate

    desc "database", t("cli.database.subcommand")
    subcommand "database", Database

    desc "config", t("cli.config.subcommand")
    subcommand "config", Config

    desc "display file [key...]", t("cli.display_values")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    method_option :locales, type: :string, desc: t("cli.locales_to_display")
    method_option :sentences, type: :boolean, desc: t("cli.display_sentences")
    # Display values from a resource bundle
    # @param file [String] Path to resource file
    # @param keys [Array<String>] Optional list of locales
    # @return [void]
    def display(file, *keys)
      run do
        source = Translatomatic::ResourceFile.load(file)
        keys = source.properties.keys if keys.empty?
        display_keys(source, keys)

        # TODO: if locales not specified, determine the list of locales from
        # all the files in the resource bundle.
        locales = parse_list(options[:locales])
        locales << Translatomatic::Locale.default.to_s if locales.empty?
        locales.each do |tag|
          locale = locale(tag)
          next if locale == source.locale
          display_properties(source, keys, locale)
        end
      end
    end

    desc "strings file [file...]", t("cli.extract_strings")
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

    desc "list", t("cli.list_backends")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # List available translator services
    # @return [void]
    def list
      run { puts Translatomatic::Translator.list }
    end

    desc 'version', t("cli.display_version")
    thor_options(self, Translatomatic::CLI::CommonOptions)
    # Display version number
    # @return [void]
    def version
      puts "Translatomatic v#{Translatomatic::VERSION}"
    end

    private

    def display_properties(source, keys, locale)
      path = source.locale_path(locale)
      if path.exist?
        resource = Translatomatic::ResourceFile.load(path)
        display_keys(resource, keys)
      end
    end

    def display_keys(source, keys)
      puts t("cli.file_source", file: source)
      rows = []
      keys.each do |key|
        value = source.get(key)
        rows << [key + ":", value]
      end
      print_table(rows, indent: 2)

      if options[:sentences]
        puts t("cli.sentences")
        source.sentences.each do |sentence|
          puts "- " + sentence.to_s
        end
      end

      puts
    end

  end # class
end   # module
