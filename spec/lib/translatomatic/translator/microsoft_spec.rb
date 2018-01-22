RSpec.describe Translatomatic::Translator::Microsoft do
  it 'requires an api key' do
    ENV['MICROSOFT_API_KEY'] = nil
    expect { described_class.new }.to raise_error(t('translator.microsoft.key_required'))
  end

  # TODO
  #   it "returns a language list" do
  #     t = described_class.new(microsoft_api_key: "dummy")
  #     expect(t.languages).to_not be_empty
  #   end

  it 'translates strings' do
    post_body = fixture_read('translator/microsoft_post.xml').chomp
    post_headers = test_http_headers.merge(
      'Content-Type' => 'application/xml',
      'Host' => 'api.microsofttranslator.com',
      'Ocp-Apim-Subscription-Key' => 'dummy'
    )
    expected_response = fixture_read('translator/microsoft_response.xml')

    stub_request(:post, 'https://api.microsofttranslator.com/V2/Http.svc/TranslateArray').with(
      body: post_body,
      headers: post_headers
    ).to_return(
      status: 200,
      body: expected_response,
      headers: {}
    )
    t = described_class.new(microsoft_api_key: 'dummy')
    results = t.translate('Beer', 'en', 'de')
    expect(results).to eq(['Bier'])
  end

  private

  def expected_headers(options = {})
    test_http_headers.merge('User-Agent' => 'Ruby').merge(options)
  end
end
