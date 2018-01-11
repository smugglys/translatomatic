module Helpers
  TMP_PATH = File.join(__dir__, "..", "tmp")
  CONFIG_PATH = File.join(".translatomatic/config.yml")
  TEST_USER_SETTINGS_PATH = File.join(TMP_PATH, CONFIG_PATH)
  TEST_PROJ_SETTINGS_PATH = File.join(TMP_PATH, "project", CONFIG_PATH)
  FIXTURES_PATH = File.join(__dir__, '..', 'fixtures')

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
    [TEST_USER_SETTINGS_PATH, TEST_PROJ_SETTINGS_PATH].each do |file|
      File.delete(file) if File.exist?(file)
    end
    config = Translatomatic.config
    config.send(:user_settings_path=, TEST_USER_SETTINGS_PATH)
    config.send(:project_settings_path=, TEST_PROJ_SETTINGS_PATH)
  end

  def fixture_read(path, crlf = false)
    contents = File.read(fixture_path(path))
    contents.gsub!(/\r\n/, "\n")
    contents.gsub!(/\n/, "\r\n") if crlf
    contents
  end

  def fixture_path(path)
    f1 = File.join(FIXTURES_PATH, path)
    return f1 if File.exist?(f1)
    f2 = File.join(FIXTURES_PATH, "resource_file", path)
    return f2 if File.exist?(f2)
    raise "fixture #{path} not found"
  end

  def database_disabled?
    TestConfig.instance.database_disabled
  end

  def test_http_headers(options = {})
    TestConfig::DEFAULT_HTTP_HEADERS.merge(options)
  end

  # create a temporary file, return path to file
  def create_tempfile(name, contents = nil)
    path = name.kind_of?(Pathname) ? name : Pathname.new(name)
    # keep extension in tempfile
    tempfile = Tempfile.new([path.basename(path.extname).to_s, path.extname])
    tempfile.write(contents) if contents
    tempfile.close
    Pathname.new(tempfile.path)
  end

  def remove_xml_whitespace(xml)
    xml.gsub(/[\r\n\t]+/, " ").gsub(/>\s*</, "><").strip
  end
end
