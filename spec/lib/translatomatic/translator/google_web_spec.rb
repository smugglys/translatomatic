RSpec.describe Translatomatic::Translator::GoogleWeb do
  include_examples 'a translator'

  def mock_languages
    stub_request(:get, "https://translate.google.com/").
      with(headers: test_http_headers).
      to_return(status: 200, body: "['en','de']", headers: {})
  end

  def mock_translation(translator, strings, from, to, results)
    alternatives = nil
    if strings.length == 1 && results.length > 1
      # use alternatives
      alternatives = results
      results = [nil]  # it should use the value of alternatives
    end

    mock_api(translator, results, alternatives)
  end

  def mock_api(translator, results, alternatives = nil)
    mock_api = double(:api)
    responses = []
    results.each do |result|
      mock_response = double(:response)
      allow(mock_response).to receive(:translation).and_return(result)
      allow(mock_response).to receive(:alternatives).and_return(alternatives)
      responses << mock_response
    end
    expect(mock_api).to receive(:translate).and_return(*responses)
    allow(translator).to receive(:api).and_return(mock_api)
  end
end
