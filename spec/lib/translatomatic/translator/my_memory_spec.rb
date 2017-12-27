RSpec.describe Translatomatic::Translator::MyMemory do
  it "creates a translator" do
    t = described_class.new
    expect(t).to be
  end

  # TODO
  #it "returns a language list" do
  #end

  it "translates strings" do
    api_endpoint = "https://api.mymemory.translated.net/get?langpair=en%7Cde&q=Beer"
    expected_response = { "responseData": { "translatedText": "Bier" } }
    stub_request(:get, api_endpoint).
      with(headers: test_http_headers('Host'=>'api.mymemory.translated.net')).
      to_return(status: 200, body: expected_response.to_json, headers: {})

    t = described_class.new
    results = t.translate("Beer", "en", "de")
    expect(results).to eq(["Bier"])
    expect(WebMock).to have_requested(:get, api_endpoint)
  end

  it "shares translated strings" do
    stub_request(:post, "https://api.mymemory.translated.net/tmx/import").
    with(headers: test_http_headers('Host'=>'api.mymemory.translated.net',
      'Content-Type' => 'multipart/form-data')).
    to_return(status: 200, body: "", headers: {})

    tmx = build(:tmx_document)
    t = described_class.new
    t.upload(tmx)
  end
end
