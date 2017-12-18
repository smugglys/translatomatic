class Translatomatic::Translation

=begin
  Method:
  - find input file(s) to translate, and associated output file(s)
  - get translator to use, specified in options or one that can work
  - read input files and find all strings to translate
  - get existing translations from database
  - translate translations not in database
  - write translated target files
=end
  attr_reader :config

  def initialize(options = {})
    @config = Config.new(options)
    db = Database.new(@config)
    db.migrate
  end

  def translate(file)
    # get input resource bundle
    bundle = ResourceBundle.from_property_file(file)
    config.logger.info "bundle: #{bundle}"

    src = bundle.source
    bundle.targets.each do |target|
      from_lang = src.locale.language
      to_lang = target.locale.language

      if from_lang == to_lang
        target.properties = source.properties
      else
        # translate strings
        strings = []
        src.properties.each do |key, value|
          strings << value
        end
        result = config.translator.translate(strings, from_lang, to_lang)
        src.properties.each do |key, value|
          translation = result.shift
          target.set(key, translation)
          config.logger.trace("translated #{value} -> #{result}")
        end
      end
      target.save
    end
  end

end
