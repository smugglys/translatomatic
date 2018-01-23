require 'fileutils'

RSpec.shared_examples 'a translator' do
  include Helpers

  def self.translator_class
    described_class
  end

  context '#new' do
    it 'creates a new translator instance' do
      expect(create_instance).to be_present
    end
  end

  context '#languages' do
    it "returns supported languages" do
      t = create_instance
      mock_languages
      expect(t.languages).to be_present
    end
  end

  context '#translate' do
    it 'translates a string' do
      translator = create_instance
      mock_translation(translator, ['Beer'], 'en', 'de', ['Bier'])
      translations = translator.translate('Beer', 'en', 'de')
      expect(translations.length).to eq(1)
      expect(translations[0].original).to eq(string("Beer", "en"))
      expect(translations[0].result).to eq(string("Bier", "de"))
    end

    it 'translates multiple strings' do
      strings = ['string1', 'string2']
      results = ['result1', 'result2']
      translator = create_instance
      mock_translation(translator, strings, 'en', 'de', results)
      translations = translator.translate(strings, 'en', 'de')
      expect(translations.length).to eq(2)
      expect(translations[0].original).to eq(string("string1", "en"))
      expect(translations[0].result).to eq(string("result1", "de"))
      expect(translations[1].original).to eq(string("string2", "en"))
      expect(translations[1].result).to eq(string("result2", "de"))
    end

    if translator_class.supports_multiple_translations?
      it 'translates a string to multiple alternatives' do
        strings = ['string1']
        results = ['result1', 'result2']
        translator = create_instance
        mock_translation(translator, strings, 'en', 'de', results)
        translations = translator.translate(strings, 'en', 'de')
        expect(translations.length).to eq(2)
        expect(translations[0].original).to eq(string("string1", "en"))
        expect(translations[0].result).to eq(string("result1", "de"))
        expect(translations[1].original).to eq(string("string1", "en"))
        expect(translations[1].result).to eq(string("result2", "de"))
      end
    end
  end

  def mock_languages
    # override to set up languages request
  end

  def mock_translation(_translator, _strings, _from, _to, _results)
    # override to set up translation requests
  end

  def create_instance
    # override to create a translator instance
    described_class.new
  end

end
