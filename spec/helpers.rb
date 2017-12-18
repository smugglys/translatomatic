module Helpers
  def fixture_read(path)
    File.read(fixture_path(path))
  end

  def fixture_path(path)
    File.join(File.dirname(__FILE__), 'fixtures', path)
  end

  def create_test_database
    config = Translatomatic::Config.new(database_env: "test")
    db = Translatomatic::Database.new(config)
    config.logger.debug "Setting up test database"
    db.drop
    db.migrate
  end

end
