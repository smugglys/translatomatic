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

    # WebMock does not support matching body for multipart/form-data requests yet :(
=begin
    stub_request(:post, "https://api.mymemory.translated.net/tmx/import").
    with(headers: test_http_headers('Host'=>'api.mymemory.translated.net',
      'Content-Type' => 'multipart/form-data')) { |request|
        request.body.match(/.*/)
      }
=end
    t = described_class.new

    tmx = double(:tmx_document)
    expect(tmx).to receive(:to_xml).and_return("<xml />")

    client = double(:client)
    response = double(:response)
    allow(response).to receive(:body).and_return("")
    expect(t).to receive(:http_client).and_return(client)
    expect(client).to receive(:post).and_return(response)

    t.upload(tmx)
  end
end
