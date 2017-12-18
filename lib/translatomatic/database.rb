require 'active_record'

class Translatomatic::Database

  DB_PATH = File.join(File.dirname(__FILE__), "db")
  DEFAULT_DB_CONFIG = File.join(DB_PATH, "database.yml")
  MIGRATIONS_PATH = File.join(DB_PATH, "migrate")
  GEM_ROOT = File.join(File.dirname(__FILE__), "..", "..")

  def initialize(config)
    @config = config
    dbconfig = File.read(config.database_config)
    dbconfig.gsub!(/\$HOME/, Dir.home)
    dbconfig.gsub!(/\$GEM_ROOT/, GEM_ROOT)
    @env = config.database_env
    @db_config = YAML::load(dbconfig) || {}
    @env_config = @db_config
    @env_config = @env_config[@env]
    ActiveRecord::Base.configurations = @db_config
    ActiveRecord::Tasks::DatabaseTasks.env = @env
    ActiveRecord::Tasks::DatabaseTasks.db_dir = DB_PATH
    ActiveRecord::Tasks::DatabaseTasks.root = DB_PATH
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = @db_config
  end

  def connect
    ActiveRecord::Base.establish_connection(@env_config)
  end

  def migrate
    connect
    ActiveRecord::Migrator.migrate(MIGRATIONS_PATH)
    ActiveRecord::Base.clear_cache!
    @config.logger.debug "Database migrated."
  end

  def create
    ActiveRecord::Tasks::DatabaseTasks.create(@env_config)
    @config.logger.debug "Database created."
  end

  def drop
    ActiveRecord::Tasks::DatabaseTasks.drop(@env_config)
    @config.logger.debug "Database deleted."
  end
end
