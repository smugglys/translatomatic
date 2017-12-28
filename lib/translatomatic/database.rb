require 'active_record'

class Translatomatic::Database

  include Translatomatic::Util

  class << self
    attr_reader :options
    private
    include Translatomatic::DefineOptions
  end

  def initialize(options = {})
    db_config_path = db_config_path(options)
    dbconfig = File.read(db_config_path)
    dbconfig.gsub!(/\$HOME/, Dir.home)
    dbconfig.gsub!(/\$GEM_ROOT/, GEM_ROOT)
    @env = options[:database_env] || DEFAULT_ENV
    @db_config = YAML::load(dbconfig) || {}
    @env_config = @db_config
    raise "no environment '#{@env}' in #{db_config_path}" unless @env_config[@env]
    @env_config = @env_config[@env]
    ActiveRecord::Base.configurations = @db_config
    ActiveRecord::Tasks::DatabaseTasks.env = @env
    ActiveRecord::Tasks::DatabaseTasks.db_dir = DB_PATH
    ActiveRecord::Tasks::DatabaseTasks.root = DB_PATH
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = @db_config
    create unless exists?
    migrate
  end

  # Connect to the database
  # @return [void]
  def connect
    ActiveRecord::Base.establish_connection(@env_config)
  end

  # Disconnect from the database
  # @return [void]
  def disconnect
    ActiveRecord::Base.remove_connection
  end

  # Test if the database exists
  # @return [Boolean] true if the database exists
  def exists?
    begin
      connect
      ActiveRecord::Base.connection.tables
    rescue
      return false
    end
    true
  end

  # Run outstanding migrations against the database
  # @return [void]
  def migrate
    connect
    ActiveRecord::Migrator.migrate(MIGRATIONS_PATH)
    ActiveRecord::Base.clear_cache!
    log.debug "Database migrated."
  end

  # Create the database
  # @return [void]
  def create
    ActiveRecord::Tasks::DatabaseTasks.create(@env_config)
    log.debug "Database created."
  end

  # Drop the database
  # @return [void]
  def drop
    disconnect
    ActiveRecord::Tasks::DatabaseTasks.drop(@env_config)
    log.debug "Database deleted."
  end

  private

  DB_PATH = File.join(File.dirname(__FILE__), "..", "..", "db")
  INTERNAL_DB_CONFIG = File.join(DB_PATH, "database.yml")
  CUSTOM_DB_CONFIG = File.join(Dir.home, ".translatomatic", "database.yml")
  DEFAULT_DB_CONFIG = File.exist?(CUSTOM_DB_CONFIG) ? CUSTOM_DB_CONFIG : INTERNAL_DB_CONFIG
  MIGRATIONS_PATH = File.join(DB_PATH, "migrate")
  GEM_ROOT = File.join(File.dirname(__FILE__), "..", "..")
  DEFAULT_ENV = "production"

  define_options(
    { name: :database_config, description: "Database config file",
      default: DEFAULT_DB_CONFIG },
    { name: :database_env, description: "Database environment",
      default: DEFAULT_ENV })

  def db_config_path(options)
    if options[:database_env] == "test"
      INTERNAL_DB_CONFIG  # rspec
    elsif options[:database_config]
      return options[:database_config]
    else
      DEFAULT_DB_CONFIG
    end
  end
end
