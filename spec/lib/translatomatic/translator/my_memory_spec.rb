RSpec.describe Translatomatic::Translator::MyMemory do
  include_examples 'a translator'

  it "shares translated strings" do
    # WebMock does not support matching body for multipart/form-data requests yet :(
    t = create_instance

    tmx = double(:tmx_document)
    expect(tmx).to receive(:to_xml).and_return("<xml />")

    client = double(:client)
    response = double(:response)
    allow(response).to receive(:body).and_return("")
    expect(t).to receive(:http_client).and_return(client)
    expect(client).to receive(:post).and_return(response)

    t.upload(tmx)
  end

  def create_instance
    described_class.new(frengly_email: 'dummy', frengly_password: 'dummy')
  end

  def mock_translation(translator, strings, from, to, results)
    api_endpoint = described_class::GET_URL
    strings.zip(results).each do |string, result|
      query = { langpair: "#{from}-#{to}", q: string }
      expected_response = { "responseData": { "translatedText": result } }

      # with(query: query) not working due to '-' escaping
      uri = URI.parse(api_endpoint)
      uri.query = URI.encode_www_form(query)
      uri = uri.to_s.gsub(/-/, "%7C") # hack to satisfy webmock

      stub_request(:get, uri).
        with(headers: test_http_headers('Host'=>'api.mymemory.translated.net')).
        to_return(status: 200, body: expected_response.to_json, headers: {})
    end
  end
end
