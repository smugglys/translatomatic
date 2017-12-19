module Helpers

  def fixture_read(path)
    File.read(fixture_path(path))
  end

  def fixture_path(path)
    File.join(File.dirname(__FILE__), 'fixtures', path)
  end

  def create_test_database
    db = Translatomatic::Database.new(env: "test")
    #config.logger.debug "Setting up test database"
    db.drop
    db.migrate
  end

  def create_tempfile(name, contents)
    tempfile = Tempfile.new(name)
    tempfile.write(contents)
    tempfile.close
    tempfile.path
  end
end
