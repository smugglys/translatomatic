module DatabaseHelpers
  def create_locale(attributes = {})
    Translatomatic::Model::Locale.find_or_create_by!(attributes)
  end

  def create_text(attributes = {})
    Translatomatic::Model::Text.find_or_create_by!(attributes)
  end

  def database_disabled?
    TestConfig.instance.database_disabled
  end

  # check if a test database can be used.
  # connects to test database.
  # returns translatomatic database object, or nil if disabled
  def use_test_database
    # log.debug "Setting up test database"
    options = { database_env: 'test' }
    if Translatomatic::Database.enabled?(options)
      Translatomatic::Database.new(options)
    else
      # log.debug "database is disabled"
      TestConfig.instance.database_disabled = true
      nil
    end
  end

  def create_test_database
    db = use_test_database
    if db
      db.drop
      db.migrate
    end
  end
end
