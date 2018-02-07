require 'active_record'

module Translatomatic
  # Database functions
  class Database
    class << self
      # @param options [Hash<Symbol,Object>] Database options
      # @return [boolean] True if we can connect to the database
      def enabled?(options = {})
        new(options).connect
      end
    end

    def initialize(options = {})
      @env = options[:database_env] || DEFAULT_ENV
      @db_config = database_config(@env, options)
      env_config = @db_config
      unless env_config[@env]
        raise t('database.no_environment', env: @env, file: db_config_path)
      end
      @env_config = env_config[@env] || {}
      init_active_record
      create unless exists?
    end

    # Connect to the database
    # @return [boolean] True if the connection was established
    def connect
      ActiveRecord::Base.establish_connection(@env_config)
      migrate
      true
    rescue LoadError
      false
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
      rescue StandardError
        return false
      end
      true
    end

    # Run outstanding migrations against the database
    # @return [void]
    def migrate
      return if @migrated
      ActiveRecord::Migrator.migrate(MIGRATIONS_PATH)
      ActiveRecord::Base.clear_cache!
      log.debug t('database.migrated')
      @migrated = true
    end

    # Create the database
    # @return [boolean] True if the database was created
    def create
      ActiveRecord::Tasks::DatabaseTasks.create(@env_config)
      log.debug t('database.created')
      true
    rescue LoadError => e
      log.debug t('database.could_not_create')
      log.error e.message
      false
    end

    # Drop the database
    # @return [void]
    def drop
      disconnect
      ActiveRecord::Tasks::DatabaseTasks.drop(@env_config)
      log.debug t('database.deleted')
    end

    # Shortcut to text model class
    # @return [Class] Translatomatic::Model::Text
    def text
      Translatomatic::Model::Text
    end

    # Shortcut to locale model class
    # @return [Class] Translatomatic::Model::Locale
    def locale
      Translatomatic::Model::Locale
    end

    private

    include Translatomatic::Util
    include Translatomatic::DefineOptions

    class << self
      private

      def join_path(*parts)
        File.realpath(File.join(*parts))
      end
    end

    def init_active_record
      ActiveRecord::Base.configurations = @db_config
      ActiveRecord::Tasks::DatabaseTasks.env = @env
      ActiveRecord::Tasks::DatabaseTasks.db_dir = DB_PATH
      ActiveRecord::Tasks::DatabaseTasks.root = DB_PATH
      ActiveRecord::Tasks::DatabaseTasks.database_configuration = @db_config
    end

    def sqlite_database_exists?
      @env_config['adapter'] == 'sqlite3' &&
        File.exist?(@env_config['database'])
    end

    DB_PATH = join_path(File.dirname(__FILE__), '..', '..', 'db')
    INTERNAL_CONF = File.join(DB_PATH, 'database.yml')
    CUSTOM_CONF = File.join(Dir.home, '.translatomatic', 'database.yml')
    DEFAULT_CONF = File.exist?(CUSTOM_CONF) ? CUSTOM_CONF : INTERNAL_CONF
    MIGRATIONS_PATH = File.join(DB_PATH, 'migrate')
    GEM_ROOT = join_path(File.dirname(__FILE__), '..', '..')
    DEFAULT_ENV = 'production'.freeze

    define_option :database_config, desc: t('database.config_file'),
                                    default: DEFAULT_CONF, type: :path
    define_option :database_env, desc: t('database.env'),
                                 default: DEFAULT_ENV

    # return path to database config
    def database_config_path(options)
      if options[:database_env] == 'test'
        INTERNAL_CONF # used for rspec
      elsif options[:database_config]
        options[:database_config]
      else
        DEFAULT_CONF
      end
    end

    # return database config as a hash
    def database_config(env, options)
      if options[:database_config].is_a?(Hash)
        return { env => options[:database_config] }
      end

      db_config_path = database_config_path(options)
      dbconfig = File.read(db_config_path)
      dbconfig.gsub!(/\$HOME/, Dir.home)
      dbconfig.gsub!(/\$GEM_ROOT/, GEM_ROOT)
      YAML.safe_load(dbconfig) || {}
    end
  end
end
