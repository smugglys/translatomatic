RSpec.describe Translatomatic::Translator::Yandex do
  it "requires an api key" do
    ENV["YANDEX_API_KEY"] = nil
    expect { described_class.new }.to raise_error(t("translator.yandex_key_required"))
  end

  it "returns a language list" do
    expected_response = {"dirs":["az-ru","be-bg","be-cs"]}
    puts expected_response.to_json
    stub_request(:post, "https://translate.yandex.net/api/v1.5/tr.json/getLangs").
         with(body: "key=dummy",
              headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(status: 200, body: expected_response.to_json, headers: {
           'Content-Type': 'application/json; charset=utf-8'
           })

    t = described_class.new(yandex_api_key: "dummy")
    expect(t.languages).to_not be_empty
  end

  it "translates strings" do
    api_endpoint = "https://translate.yandex.net/api/v1.5/tr.json/translate"
    expected_response = { "code": 200, "lang": "en-de", "text": ["Bier"] }
    puts expected_response.to_json
    stub_request(:post, api_endpoint).
    with(body: "text=Beer&lang=en-de&key=dummy",
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: expected_response.to_json, headers: {
          'Content-Type': 'application/json; charset=utf-8'
          })

    t = described_class.new(yandex_api_key: "dummy")
    results = t.translate("Beer", "en", "de")
    expect(results).to eq(["Bier"])
    expect(WebMock).to have_requested(:post, api_endpoint)
  end
end
