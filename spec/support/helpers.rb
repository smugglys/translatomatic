module Helpers
  TMP_PATH = File.join(__dir__, '..', 'tmp')
  CONFIG_PATH = File.join('.translatomatic/config.yml')
  TEST_USER_SETTINGS_PATH = File.join(TMP_PATH, CONFIG_PATH)
  TEST_PROJ_SETTINGS_PATH = File.join(TMP_PATH, 'project', CONFIG_PATH)
  FIXTURES_PATH = File.join(__dir__, '..', 'fixtures')

  def use_test_config
    [TEST_USER_SETTINGS_PATH, TEST_PROJ_SETTINGS_PATH].each do |file|
      File.delete(file) if File.exist?(file)
    end
    config = Translatomatic.config
    config.send(:user_settings_path=, TEST_USER_SETTINGS_PATH)
    config.send(:project_settings_path=, TEST_PROJ_SETTINGS_PATH)

    # patch http request so we can match multipart bodies
    # WebMock does not support matching body for multipart/form-data requests yet :(
    # Translatomatic::HTTP::Request.prepend Helpers::MultipartPatch
  end

  def fixture_read(path, crlf = false)
    contents = Translatomatic::Slurp.read(fixture_path(path))
    contents.gsub!(/\r\n/, "\n")
    contents.gsub!(/\n/, "\r\n") if crlf
    contents
  end

  def fixture_path(path = nil, options = {})
    return FIXTURES_PATH if path.nil?
    return path if File.exist?(path)
    f1 = File.join(FIXTURES_PATH, path)
    return f1 if File.exist?(f1)
    f2 = File.join(FIXTURES_PATH, 'resource_file', path)
    return f2 if File.exist?(f2)
    raise "fixture #{path} not found" unless options[:allow_missing]
    nil
  end

  def test_http_headers(options = {})
    TestConfig::DEFAULT_HTTP_HEADERS.merge(options)
  end

  # create a temporary file, return path to file
  def create_tempfile(name, contents = nil)
    path = name.is_a?(Pathname) ? name : Pathname.new(name)
    # keep extension in tempfile
    tempfile = Tempfile.new([path.basename(path.extname).to_s, path.extname])
    tempfile.write(contents) if contents
    tempfile.close
    Pathname.new(tempfile.path)
  end

  def remove_xml_whitespace(xml)
    xml.gsub(/[\r\n\t]+/, ' ').gsub(/>\s*</, '><').strip
  end
end
