RSpec.describe Translatomatic::Provider::Frengly do
  include_examples 'a provider'

  it 'requires an email' do
    ENV['FRENGLY_API_KEY'] = nil
    expect { described_class.new }.to raise_error(t('provider.email_required'))
  end

  it 'requires a password' do
    expect do
      described_class.new(frengly_email: 'rah')
    end.to raise_error(t('provider.password_required'))
  end

  def create_instance
    described_class.new(frengly_email: 'dummy', frengly_password: 'dummy')
  end

  def mock_translation(provider, strings, from, to, results)
    api_endpoint = 'http://frengly.com/frengly/data/translateREST'
    strings.zip(results).each do |string, result|
      expected_response = {
        status: 200, body: { text: result }.to_json, headers: {}
      }
      request_body = {
        src: "en", dest: "de", text: string, email: "dummy",
        password: "dummy", premiumkey: nil
      }
      stub_request(:post, api_endpoint)
        .with(body: request_body,
              headers: test_http_headers('Host' => 'frengly.com'))
        .to_return(expected_response)
    end

  end
end
