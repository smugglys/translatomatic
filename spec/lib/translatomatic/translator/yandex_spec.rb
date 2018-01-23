RSpec.describe Translatomatic::Translator::Yandex do
  include_examples 'a translator'

  it "requires an api key" do
    ENV["YANDEX_API_KEY"] = nil
    expect {
      described_class.new
    }.to raise_error(t("translator.yandex.key_required"))
  end

  def create_instance
    described_class.new(yandex_api_key: 'dummy')
  end

  def mock_languages
    expected_response = { "langs": {
        "ru": "Russian",
        "en": "English",
        "pl": "Polish"
      }
    }

    request_body = { key: "dummy", ui: "en" }
    stub_request(:post, "https://translate.yandex.net/api/v1.5/tr.json/getLangs").
         with(body: request_body, headers: request_headers).
         to_return(status: 200, body: expected_response.to_json)
  end

  def mock_translation(translator, strings, from, to, results)
    api_endpoint = "https://translate.yandex.net/api/v1.5/tr.json/translate"
    #WebMock::Config.instance.query_values_notation = :flat_array

    response_body = {
      "code": 200, "lang": "#{from}-#{to}", "text": results
    }
    expected_response = {
      status: 200,
      body: response_body.to_json,
      headers: {
        'Content-Type': 'application/json; charset=utf-8'
      }
    }

    if strings.length > 1
      # webmock not working with "text" => [string1, string2]
      request_text = /.*/
    else
      request_text = strings[0]
    end
    request_body = {
      "format" => "plain", "key"=>"dummy", "lang"=>"#{from}-#{to}",
      "text" => request_text
    }
    stub_request(:post, api_endpoint).
      with(body: request_body, headers: request_headers).
      to_return(expected_response)
  end

  def request_headers
    test_http_headers(
      'Content-Type'=>'application/x-www-form-urlencoded',
      'Host'=>'translate.yandex.net'
    )
  end

  def flatten_params(params)
    list = []
    params.each do |key, value|
      if value.is_a?(Array)
        value.each { |i| list << [key.to_s, i.to_s] }
      else
        list << [key.to_s, value.to_s]
      end
    end
    list
  end
end
