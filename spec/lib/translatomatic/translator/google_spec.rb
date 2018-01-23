RSpec.describe Translatomatic::Translator::Google do
  include_examples 'a translator'

  it "requires an api key" do
    ENV["GOOGLE_API_KEY"] = nil
    expect { described_class.new }.to raise_error(t("translator.google.key_required"))
  end

  def create_instance
    described_class.new(google_api_key: 'dummy')
  end

  def mock_languages
    api_endpoint = "https://translation.googleapis.com/language/translate/v2/languages?key=dummy"
    expected_response = {
      "data"=>{"languages"=>[{"language"=>"af"}, {"language"=>"am"}]}
    }
    stub_request(:get, api_endpoint).
      with(headers: test_http_headers).
      to_return(status: 200, body: expected_response.to_json, headers: {})
  end

  def mock_translation(translator, strings, from, to, results)
    api_endpoint = "https://translation.googleapis.com/language/translate/v2"
    translations = results.collect do |result|
      { "translatedText": result }
    end
    expected_response = {
      "data": { "translations": translations }
    }

    if strings.length > 1
      # webmock not working with "text" => [string1, string2]
      expected_q = /.*/
    else
      expected_q = strings[0]
    end
    headers = test_http_headers(
      'Content-Type'=>'application/x-www-form-urlencoded'
    )
    body = {
      "format"=>"text", "key"=>"dummy", "q" => expected_q,
      "source"=>"en", "target"=>"de"
    }
    stub_request(:post, api_endpoint).
      with(body: body, headers: headers).
      to_return(status: 200, body: expected_response.to_json, headers: {})
  end
end
