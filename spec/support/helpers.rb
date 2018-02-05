module Helpers
  TMP_PATH = File.join(__dir__, '..', 'tmp')
  CONFIG_PATH = File.join('.translatomatic/config.yml')
  TEST_USER_PATH = TMP_PATH
  TEST_PROJ_PATH = File.join(TMP_PATH, 'project')
  FIXTURES_PATH = File.join(__dir__, '..', 'fixtures')

  def use_test_config(options = {})
    unless options && options[:keep_config]
      [TEST_USER_PATH, TEST_PROJ_PATH].each do |file|
        config = File.join(file, CONFIG_PATH)
        File.delete(config) if File.exist?(config)
      end
    end
    params = {
      user_path: TEST_USER_PATH,
      project_path: TEST_PROJ_PATH
    }.merge(options)
    Translatomatic.config = Translatomatic::Config::Settings.new(params)

    # patch http request so we can match multipart bodies
    # WebMock does not support matching body for multipart/form-data requests yet :(
    # Translatomatic::HTTP::Request.prepend Helpers::MultipartPatch
  end

  def reset_test_config(options = {})
    use_test_config(options)
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

  def absolute_path(*args)
    File.absolute_path(File.join(*args))
  end

  def config_file_path(path)
    return nil unless path
    File.join(path, ".translatomatic", "config.yml")
  end

  def dump_config(location, path)
    config_path = config_file_path(path)
    content = File.read(config_path) if config_path && File.exist?(config_path)
    puts "#{location} config:"
    puts content ? content : "(empty)"
  end

  def dump_all_config
    dump_config(:user, config.user_path)
    dump_config(:project, config.project_path)
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
