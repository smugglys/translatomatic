RSpec.describe Translatomatic::Translator do
  describe :new do
    it 'should create a translator instance' do
      translator = create_translator
      expect(translator).to be
    end
  end

  describe :translate do
    it 'should translate a string' do
      translator = create_translator
      string = string('Test string', 'en')
      result = translator.translate(string, 'de')
      expect(result).to be
      expect(result.length).to eq(1)
      expect(result[0]).to be_a(Translatomatic::Translation)
    end
  end

  def create_translator(options = {})
    Translatomatic::Translator.new(options)
  end
end
