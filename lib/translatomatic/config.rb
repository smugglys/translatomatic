
class Translatomatic::Config

  attr_reader :database_config
  attr_reader :database_env
  attr_reader :translator
  attr_reader :logger
  attr_reader :google_api_key
  attr_reader :yandex_api_key
  attr_reader :bing_api_key

  def initialize(options = {})
    @logger = options[:logger] || Logger.new(STDOUT)
    @debug = options[:debug] || (ENV['DEBUG'] ? true : false)
    @google_api_key = options[:google_api_key] || ENV["GOOGLE_API_KEY"]
    @yandex_api_key = options[:yandex_api_key] || ENV["YANDEX_API_KEY"]
    @bing_api_key = options[:bing_api_key] || ENV["BING_API_KEY"]
    @translator = Translatomatic::Translator.find(options[:translator])
    @database_env = options[:database_env] || "default"
    @database_config = options[:database_config] ||
      Translatomatic::Database::DEFAULT_DB_CONFIG
  end

  def debug?
    @debug
  end
end
