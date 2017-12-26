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
    options = { database_env: "test" }
    if Translatomatic::Database.enabled?(options)
      db = Translatomatic::Database.new(options)
      db.drop
      db.migrate
    else
      log.debug "database is disabled"
      TestConfig.instance.database_disabled = true
    end
  end

  def database_disabled?
    TestConfig.instance.database_disabled
  end

  def create_tempfile(name, contents = nil)
    tempfile = Tempfile.new(name)
    tempfile.write(contents) if contents
    tempfile.close
    Pathname.new(tempfile.path)
  end

  def remove_xml_whitespace(xml)
    xml.gsub(/[\r\n\t]+/, " ").gsub(/>\s*</, "><").strip
  end
end
