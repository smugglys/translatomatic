module Helpers
  include Translatomatic::Util

  def fixture_read(path)
    File.read(fixture_path(path))
  end

  def fixture_path(path)
    File.join(File.dirname(__FILE__), '..', 'fixtures', path)
  end

  def create_test_database
    log.debug "Setting up test database"
    db = Translatomatic::Database.new(database_env: "test")
    db.drop
    db.migrate
  end

  def create_tempfile(name, contents = nil)
    tempfile = Tempfile.new(name)
    tempfile.write(contents) if contents
    tempfile.close
    Pathname.new(tempfile.path)
  end
end
