require 'active_record'

class Translatomatic::Database

  include Translatomatic::Util

  DB_PATH = File.join(File.dirname(__FILE__), "db")
  DEFAULT_DB_CONFIG = File.join(DB_PATH, "database.yml")
  CUSTOM_DB_CONFIG = File.join(Dir.home, ".translatomatic", "database.yml")
  MIGRATIONS_PATH = File.join(DB_PATH, "migrate")
  GEM_ROOT = File.join(File.dirname(__FILE__), "..", "..")
  DEFAULT_ENV = "default"

  def initialize(options = {})
    db_config_path = db_config_path(options)
    dbconfig = File.read(db_config_path)
    dbconfig.gsub!(/\$HOME/, Dir.home)
    dbconfig.gsub!(/\$GEM_ROOT/, GEM_ROOT)
    @env = options[:env] || DEFAULT_ENV
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

  def connect
    ActiveRecord::Base.establish_connection(@env_config)
  end

  def disconnect
    ActiveRecord::Base.remove_connection
  end

  def exists?
    begin
      connect
      ActiveRecord::Base.connection.tables
    rescue
      return false
    end
    true
  end

  def migrate
    connect
    ActiveRecord::Migrator.migrate(MIGRATIONS_PATH)
    ActiveRecord::Base.clear_cache!
    log.debug "Database migrated."
  end

  def create
    ActiveRecord::Tasks::DatabaseTasks.create(@env_config)
    log.debug "Database created."
  end

  def drop
    disconnect
    ActiveRecord::Tasks::DatabaseTasks.drop(@env_config)
    log.debug "Database deleted."
  end

  private

  def db_config_path(options)
    if options[:env] == "test"
      DEFAULT_DB_CONFIG  # rspec
    elsif options[:database_config]
      return options[:database_config]
    elsif File.exist?(CUSTOM_DB_CONFIG)
      CUSTOM_DB_CONFIG
    else
      DEFAULT_DB_CONFIG
    end
  end
end
