RSpec.describe Translatomatic::Translator::Google do
  it "requires an api key" do
    ENV["GOOGLE_API_KEY"] = nil
    expect { described_class.new }.to raise_error(t("translator.google.key_required"))
  end

  it "returns a language list" do
    api_endpoint = "https://translation.googleapis.com/language/translate/v2/languages?key=dummy"
    expected_response = {
      "data"=>{"languages"=>[{"language"=>"af"}, {"language"=>"am"}]}
    }
    stub_request(:get, api_endpoint).
      with(headers: test_http_headers).
      to_return(status: 200, body: expected_response.to_json, headers: {})

    t = described_class.new(google_api_key: "dummy")
    expect(t.languages).to eq(['af', 'am'])
  end

  it "translates strings" do
    api_endpoint = "https://translation.googleapis.com/language/translate/v2"
    expected_response = {
      "data": {
        "translations": [ { "translatedText": "Bier" } ]
      }
    }

    headers = test_http_headers('Content-Type'=>'application/x-www-form-urlencoded')
    body = {"format"=>"text", "key"=>"dummy", "q"=>"Beer", "source"=>"en", "target"=>"de"}
    stub_request(:post, api_endpoint).
      with(body: body, headers: headers).
      to_return(status: 200, body: expected_response.to_json, headers: {})

    t = described_class.new(google_api_key: "dummy")
    results = t.translate("Beer", "en", "de")
    expect(results).to eq(["Bier"])
    expect(WebMock).to have_requested(:post, api_endpoint)
  end
end
