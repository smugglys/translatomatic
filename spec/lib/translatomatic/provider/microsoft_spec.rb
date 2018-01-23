RSpec.describe Translatomatic::Provider::Microsoft do
  include_examples 'a provider'

  it 'requires an api key' do
    ENV['MICROSOFT_API_KEY'] = nil
    expect { described_class.new }.to raise_error(t('provider.microsoft.key_required'))
  end

  def mock_translation(provider, strings, from, to, results)
    post_headers = test_http_headers(
      'Content-Type' => 'application/xml',
      'Host' => 'api.microsoftprovider.com',
      'Ocp-Apim-Subscription-Key' => 'dummy'
    )
    fixture_suffix = nil
    if results.length == 1
      fixture_suffix = ''
    elsif strings.length > 1 && results.length > 1
      fixture_suffix = '_multiple'
    elsif strings.length == 1 && results.length > 1
      fixture_suffix = '_alternatives'
    else
      raise "unhandled request configuration"
    end

    expected_request = read_fixture("request", fixture_suffix)
    expected_response = read_fixture("response", fixture_suffix)

    stub_request(:post, described_class::TRANSLATE_ARRAY_N_URL).with(
      body: expected_request,
      headers: post_headers
    ).to_return(
      status: 200,
      body: expected_response,
      headers: {}
    )
  end

  def read_fixture(type, suffix)
    xml = fixture_read("provider/microsoft_#{type}#{suffix}.xml")
    xml = xml.gsub(/\n\s*/, '')
    xml
  end

  def mock_languages
    expected_response = fixture_read('provider/microsoft_languages.xml')
    request_headers = test_http_headers(
      'Host' => 'api.microsoftprovider.com',
      'Ocp-Apim-Subscription-Key' => 'dummy'
    )
    stub_request(:get, described_class::LANGUAGES_URL).
      with(query: { appid: '' }, headers: request_headers).
      to_return(status: 200, body: expected_response)
  end

  def create_instance
    described_class.new(microsoft_api_key: 'dummy')
  end

end
