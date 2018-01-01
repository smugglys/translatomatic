RSpec.describe Translatomatic::Translator::MyMemory do
  it "creates a translator" do
    ENV["MYMEMORY_API_KEY"] = nil
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

    # webmock doesn't support regex body match
=begin
    stub_request(:post, "https://api.mymemory.translated.net/tmx/import").
    with(headers: test_http_headers('Host'=>'api.mymemory.translated.net',
      'Content-Type' => 'multipart/form-data')) { |request|
        request.body.match(/.*/)
      }
=end
    request = Translatomatic::HTTPRequest.new("http://example.com")
    response = double(:response)
    allow(response).to receive(:body).and_return("")
    expect(Translatomatic::HTTPRequest).to receive(:new).and_return(request)
    expect(request).to receive(:send_request).and_return(response)

    tmx = build(:tmx_document)
    t = described_class.new
    t.upload(tmx)
  end
end
