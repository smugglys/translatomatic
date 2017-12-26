RSpec.describe Translatomatic::Translator::Microsoft do
  it "requires an api key" do
    expect { described_class.new }.to raise_error(/api key required/)
  end

  # TODO
=begin
  it "returns a language list" do
    t = described_class.new(microsoft_api_key: "dummy")
    expect(t.languages).to_not be_empty
  end
=end

  it "translates strings" do

    token_response = { token: "123" }
    stub_request(:post, "https://api.cognitive.microsoft.com/sts/v1.0/issueToken").
           with(headers: expected_headers('Ocp-Apim-Subscription-Key'=>'dummy')).
           to_return(status: 200, body: token_response.to_json, headers: {})

    # feel the power of soap
    response1 = fixture_read("translator/microsoft.wsdl.xml").strip
    stub_request(:get, "http://api.microsofttranslator.com/V2/soap.svc?wsdl").
             with(headers: expected_headers).
             to_return(status: 200, body: response1, headers: {})

    post_body = fixture_read("translator/microsoft_post.xml").strip
    response2 = fixture_read("translator/microsoft_response.xml")
    stub_request(:post, "http://api.microsofttranslator.com/V2/soap.svc").
      with(body: post_body,
          headers: expected_headers(
             'Authorization'=>'Bearer {"token":"123"}',
             'Content-Length'=>'564', 'Content-Type'=>'text/xml;charset=UTF-8',
             'Soapaction'=>'"http://api.microsofttranslator.com/V2/LanguageService/TranslateArray"')).
               to_return(status: 200, body: response2, headers: {})

    t = described_class.new(microsoft_api_key: "dummy")
    results = t.translate("Beer", "en", "de")
    expect(results).to eq(["Bier"])
  end

  private

  def expected_headers(options = {})
    test_http_headers.merge("User-Agent" => "Ruby").merge(options)
  end
end
