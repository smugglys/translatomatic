RSpec.describe Translatomatic::Translator::Frengly do
  it 'requires an email' do
    ENV['FRENGLY_API_KEY'] = nil
    expect { described_class.new }.to raise_error(t('translator.email_required'))
  end

  it 'requires a password' do
    expect do
      described_class.new(frengly_email: 'rah')
    end.to raise_error(t('translator.password_required'))
  end

  it 'returns a language list' do
    t = described_class.new(frengly_email: 'dummy', frengly_password: 'dummy')
    expect(t.languages).to_not be_empty
  end

  it 'translates strings' do
    # TODO: work out what the response looks like
    api_endpoint = 'http://frengly.com/frengly/data/translateREST'
    expected_response = { text: 'Bier' }
    stub_request(:post, api_endpoint)
      .with(body: '{"src":"en","dest":"de","text":"Beer","email":"dummy","password":"dummy","premiumkey":null}',
            headers: test_http_headers('Host' => 'frengly.com'))
      .to_return(status: 200, body: expected_response.to_json, headers: {})

    t = described_class.new(frengly_email: 'dummy', frengly_password: 'dummy')
    results = t.translate('Beer', 'en', 'de')
    expect(results).to eq(['Bier'])
    expect(WebMock).to have_requested(:post, api_endpoint)
  end
end
