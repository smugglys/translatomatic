require 'singleton'

# Translatomatic configuration
class Translatomatic::Config
  include Singleton
  include Translatomatic::Util

  # @return [Logger] The logger instance
  attr_accessor :logger

  # @return [String] The default locale
  attr_accessor :default_locale

  # Change a configuration setting
  # @param key [String] configuration key
  # @param value [String] new value for the configuration
  # @return [String] the new value
  def set(key, value)
    key = check_valid_key(key)
    @settings[key] = value
    save
  end

  # Get a configuration setting
  # @param key [String] configuration key
  # @return [String] configuration value
  def get(key)
    key = check_valid_key(key)
    option = option(key)
    if @settings.include?(key)
      cast(@settings[key], option.type)
    else
      cast(option.default, option.type)
    end
  end

  # Remove a configuration setting
  # @param key [String] configuration key to remove
  # @return [void]
  def remove(key)
    key = check_valid_key(key)
    @settings.delete(key)
    save
  end

  # Test if configuration includes the given key
  # @param key [String] configuration key
  # @return [boolean] true if the configuration key is set
  def include?(key)
    key = check_valid_key(key)
    @settings.include?(key)
  end

  # @return [Hash<String,String>] configuration settings
  def settings
    @settings.dup
  end

  # Save configuration settings
  def save
    FileUtils.mkdir_p(File.dirname(@settings_path))
    File.open(@settings_path, "w") { |f| f.puts @settings.to_yaml }
  end

  # Load configuration from the config file
  def load
    @settings = YAML.load_file(@settings_path) if File.exist?(@settings_path)
    @settings ||= {}
    @settings.delete_if { |i| !valid_key?(i) }
    @settings
  end

  # Reset all configuration to the defaults
  def reset
    @settings = {}
    save
  end

  # @return [Array<Translatomatic::Option] all available options
  def self.options
    self.config_options.values
  end

  private

  SETTINGS_PATH = File.join(Dir.home, ".translatomatic", "config.yml")

  # @return [Hash<String,Translatomatic::Option>] options
  def self.config_options
    @config_options ||= begin
      # create mapping from option name to option object
      map = {}
      sources = [
        Translatomatic::CLI::CommonOptions,
        Translatomatic::CLI::Translate,
        Translatomatic::Translator.modules,
        Translatomatic::Database,
        Translatomatic::Converter
      ]
      sources.each do |source|
        source_options = Translatomatic::Option.options_from_object(source)
        source_options.each do |sopt|
          optname = sopt.name.to_s
          raise "#{optname} already defined" if map.include?(optname)
          map[optname] = sopt
        end
      end
      map
    end
  end

  def cast(value, type)
    case type
    when :boolean
      return true if ["true", "t", "yes", "on"].include?(value)
      return false if ["false", "f", "no", "off"].include?(value)
      return value ? true : false
    when :string
      return value.nil? ? value : value.to_s
    when :array
      if value.nil?
        value = []
      else
        value = [value] unless value.kind_of?(Array)
        value = value.collect { |i| i.split(/[, ]/) }.flatten.compact
      end
    end
    value
  end

  def option(key)
    self.class.config_options[key.to_s]
  end

  def check_valid_key(key)
    key = key.to_s
    raise t("config.invalid_key", key: key) unless valid_key?(key)
    key
  end

  def valid_key?(key)
    self.class.config_options.include?(key.to_s)
  end

  # override settings path, used for testing
  def settings_path=(path)
    @settings = {}
    @settings_path = path
    load
  end

  def initialize
    @logger = Translatomatic::Logger.new
    lang = (ENV['LANG'] || '').split(/\./)[0]
    @default_locale = Translatomatic::Locale.parse(lang).language || "en"
    @settings_path = SETTINGS_PATH
    load
  end

end
