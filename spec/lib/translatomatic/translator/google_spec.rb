RSpec.describe Translatomatic::Translator::Google do
  it "requires an api key" do
    ENV["GOOGLE_API_KEY"] = nil
    expect { described_class.new }.to raise_error(t("translator.google_key_required"))
  end

  it "returns a language list" do
    t = described_class.new(google_api_key: "dummy")
    expect(t.languages).to_not be_empty
  end

  it "translates strings" do
    api_endpoint = "https://translation.googleapis.com/language/translate/v2?key=dummy&prettyPrint=false&source=en&target=de"
    expected_response = {
      "data": {
        "translations": [ { "translatedText": "Bier" } ]
      }
    }

    stub_request(:post, api_endpoint).
    with(body: "q=Beer",
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby', 'X-Http-Method-Override'=>'GET'}).
        to_return(status: 200, body: expected_response.to_json, headers: {})

    t = described_class.new(google_api_key: "dummy")
    results = t.translate("Beer", "en", "de")
    expect(results).to eq(["Bier"])
    expect(WebMock).to have_requested(:post, api_endpoint)
  end
end
