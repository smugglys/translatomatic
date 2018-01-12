class TestConfig
  include Singleton

  DEFAULT_HTTP_HEADERS = {
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent' => Translatomatic::HTTPRequest::USER_AGENT
  }.freeze

  attr_accessor :database_disabled
end
