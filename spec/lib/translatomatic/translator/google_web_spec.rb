RSpec.describe Translatomatic::Translator::GoogleWeb do
  it 'returns a language list' do
    t = described_class.new
    expect(t.languages).to_not be_empty
  end

  it 'translates to a single string' do
    t = described_class.new
    mock_api(t, 'Recht')
    results = t.translate('right', 'en', 'de')
    expect(results).to eq(['Recht'])
  end

  # TODO
=begin
  it 'translates to multiple strings' do
    t = described_class.new
    alternatives = ['Geh rechts', 'geh nach rechts', 'gehen Sie nach rechts']
    mock_api(t, 'Geh rechts', alternatives)
    results = t.translate('go right', 'en', 'de')
  end
=end

  private

  def mock_api(t, translation, alternatives = nil)
    mock_api = double(:api)
    mock_response = double(:response)
    expect(mock_response).to receive(:translation).and_return(translation)
    allow(mock_response).to receive(:alternatives).and_return(alternatives)
    expect(mock_api).to receive(:translate).and_return(mock_response)
    allow(t).to receive(:api).and_return(mock_api)
  end
end
