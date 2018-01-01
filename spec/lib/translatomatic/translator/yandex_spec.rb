RSpec.describe Translatomatic::Translator::Yandex do
  it "requires an api key" do
    ENV["YANDEX_API_KEY"] = nil
    expect { described_class.new }.to raise_error(t("translator.yandex_key_required"))
  end

  it "returns a language list" do
    expected_response = { "langs": {
        "ru": "Russian",
        "en": "English",
        "pl": "Polish"
      }
    }
    stub_request(:post, "https://translate.yandex.net/api/v1.5/tr.json/getLangs").
         with(body: { key: "dummy", ui: "en" }, headers: test_http_headers).
         to_return(status: 200, body: expected_response.to_json, headers: {
           'Content-Type': 'application/json; charset=utf-8'
           })

    t = described_class.new(yandex_api_key: "dummy")
    expect(t.languages).to_not be_empty
  end

  it "translates strings" do
    api_endpoint = "https://translate.yandex.net/api/v1.5/tr.json/translate"
    expected_response = { "code": 200, "lang": "en-de", "text": ["Bier"] }
    stub_request(:post, api_endpoint).
    with(body: { "format"=>"plain", "key"=>"dummy",
      "lang"=>"en-de", "text"=>"Beer" }, headers: test_http_headers).
        to_return(status: 200, body: expected_response.to_json, headers: {
          'Content-Type': 'application/json; charset=utf-8'
          })

    t = described_class.new(yandex_api_key: "dummy")
    results = t.translate("Beer", "en", "de")
    expect(results).to eq(["Bier"])
    expect(WebMock).to have_requested(:post, api_endpoint)
  end
end
