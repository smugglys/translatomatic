module Helpers
  TEST_SETTINGS_PATH = File.join(File.dirname(__FILE__), "..", "tmp", "config.yml")

  def create_test_database
    #log.debug "Setting up test database"
    options = { database_env: "test" }
    if Translatomatic::Database.enabled?(options)
      db = Translatomatic::Database.new(options)
      db.drop
      db.migrate
    else
      #log.debug "database is disabled"
      TestConfig.instance.database_disabled = true
    end
  end

  def use_test_config
    File.delete(TEST_SETTINGS_PATH) if File.exist?(TEST_SETTINGS_PATH)
    config = Translatomatic::Config.instance
    config.send(:user_settings_path=, TEST_SETTINGS_PATH)
  end

  def fixture_read(path, crlf = false)
    contents = File.read(fixture_path(path))
    contents.gsub!(/\r\n/, "\n")
    contents.gsub!(/\n/, "\r\n") if crlf
    contents
  end

  def fixture_path(path)
    File.join(File.dirname(__FILE__), '..', 'fixtures', path)
  end

  def database_disabled?
    TestConfig.instance.database_disabled
  end

  def test_http_headers(options = {})
    TestConfig::DEFAULT_HTTP_HEADERS.merge(options)
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
