require 'active_record'

class Translatomatic::Database

  include Translatomatic::Util

  class << self
    attr_reader :options

    # @param [Hash<Symbol,Object>] options Database options
    # @return True if we can connect to the database
    def enabled?(options = {})
      new(options).connect
    end

    private

    include Translatomatic::DefineOptions
  end

  def initialize(options = {})
    @env = options[:database_env] || DEFAULT_ENV
    @db_config = database_config(@env, options)
    @env_config = @db_config
    raise "no environment '#{@env}' in #{db_config_path}" unless @env_config[@env]
    @env_config = @env_config[@env] || {}

    ActiveRecord::Base.configurations = @db_config
    ActiveRecord::Tasks::DatabaseTasks.env = @env
    ActiveRecord::Tasks::DatabaseTasks.db_dir = DB_PATH
    ActiveRecord::Tasks::DatabaseTasks.root = DB_PATH
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = @db_config
    create unless exists?
    migrate
  end

  # Connect to the database
  # @return [boolean] True if the connection was established
  def connect
    begin
      ActiveRecord::Base.establish_connection(@env_config)
      true
    rescue LoadError
      false
    end
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
      return true if sqlite_database_exists?
      return false unless connect
      ActiveRecord::Base.connection.tables
    rescue
      return false
    end
    true
  end

  # Run outstanding migrations against the database
  # @return [void]
  def migrate
    return false unless connect
    ActiveRecord::Migrator.migrate(MIGRATIONS_PATH)
    ActiveRecord::Base.clear_cache!
    log.debug "Database migrated."
  end

  # Create the database
  # @return [boolean] True if the database was created
  def create
    begin
      ActiveRecord::Tasks::DatabaseTasks.create(@env_config)
      log.debug "Database created."
      true
    rescue LoadError => e
      log.debug "Database could not be created: " + e.message
      false
    end
  end

  # Drop the database
  # @return [void]
  def drop
    disconnect
    ActiveRecord::Tasks::DatabaseTasks.drop(@env_config)
    log.debug "Database deleted."
  end

  private

  def sqlite_database_exists?
    @env_config['adapter'] == 'sqlite3' && File.exist?(@env_config['database'])
  end

  def self.join_path(*parts)
    File.realpath(File.join(*parts))
  end

  DB_PATH = join_path(File.dirname(__FILE__), "..", "..", "db")
  INTERNAL_CONFIG = File.join(DB_PATH, "database.yml")
  CUSTOM_CONFIG = File.join(Dir.home, ".translatomatic", "database.yml")
  DEFAULT_CONFIG = File.exist?(CUSTOM_CONFIG) ? CUSTOM_CONFIG : INTERNAL_CONFIG
  MIGRATIONS_PATH = File.join(DB_PATH, "migrate")
  GEM_ROOT = join_path(File.dirname(__FILE__), "..", "..")
  DEFAULT_ENV = "production"

  define_options(
    { name: :database_config, description: "Database config file",
      default: DEFAULT_CONFIG },
    { name: :database_env, description: "Database environment",
      default: DEFAULT_ENV })

  # return path to database config
  def database_config_path(options)
    if options[:database_env] == "test"
      INTERNAL_CONFIG  # rspec
    elsif options[:database_config]
      return options[:database_config]
    else
      DEFAULT_CONFIG
    end
  end

  # return database config as a hash
  def database_config(env, options)
    if options[:database_config].kind_of?(Hash)
      return { env => options[:database_config] }
    end

    db_config_path = database_config_path(options)
    dbconfig = File.read(db_config_path)
    dbconfig.gsub!(/\$HOME/, Dir.home)
    dbconfig.gsub!(/\$GEM_ROOT/, GEM_ROOT)
    YAML::load(dbconfig) || {}
  end

end
