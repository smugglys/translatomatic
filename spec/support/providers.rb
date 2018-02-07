require 'fileutils'

RSpec.shared_examples 'a provider' do
  include Helpers

  def self.provider_class
    described_class
  end

  context '#new' do
    it 'creates a new provider instance' do
      expect(create_instance).to be_present
    end
  end

  context '#languages' do
    it 'returns supported languages' do
      t = create_instance
      mock_languages
      expect(t.languages).to be_present
    end
  end

  context '#translate' do
    it 'translates a string' do
      provider = create_instance
      mock_translation(provider, ['Beer'], 'en', 'de', ['Bier'])
      translations = provider.translate('Beer', 'en', 'de')
      expect(translations.length).to eq(1)
      expect(translations[0]).to be_a(Translatomatic::Translation::Result)
      expect(translations[0].original).to eq(build_text('Beer', 'en'))
      expect(translations[0].result).to eq(build_text('Bier', 'de'))
    end

    it 'returns original strings if target locale equals source locale' do
      provider = create_instance
      translations = provider.translate('Beer', 'en', 'en')
      expect(translations.length).to eq(1)
      expect(translations[0]).to be_a(Translatomatic::Translation::Result)
      expect(translations[0].original).to eq(build_text('Beer', 'en'))
      expect(translations[0].result).to eq(build_text('Beer', 'en'))
    end

    it 'translates multiple strings' do
      strings = %w[string1 string2]
      results = %w[result1 result2]
      provider = create_instance
      mock_translation(provider, strings, 'en', 'de', results)
      translations = provider.translate(strings, 'en', 'de')
      expect(translations.length).to eq(2)
      expect(translations[0]).to be_a(Translatomatic::Translation::Result)
      expect(translations[0].original).to eq(build_text('string1', 'en'))
      expect(translations[0].result).to eq(build_text('result1', 'de'))
      expect(translations[1]).to be_a(Translatomatic::Translation::Result)
      expect(translations[1].original).to eq(build_text('string2', 'en'))
      expect(translations[1].result).to eq(build_text('result2', 'de'))
    end

    if described_class.supports_alternative_translations?
      it 'translates a string to multiple alternatives' do
        strings = ['string1']
        results = %w[result1 result2]
        provider = create_instance

        # microsoft provider currently only does alternative translations
        # when there is a context attached to the string.
        strings = strings.collect do |i|
          build_text(i, 'en', context: 'context')
        end

        mock_translation(provider, strings, 'en', 'de', results)
        translations = provider.translate(strings, 'en', 'de')
        expect(translations.length).to eq(2)
        expect(translations[0]).to be_a(Translatomatic::Translation::Result)
        expect(translations[0].original).to eq(build_text('string1', 'en'))
        expect(translations[0].result).to eq(build_text('result1', 'de'))
        expect(translations[1]).to be_a(Translatomatic::Translation::Result)
        expect(translations[1].original).to eq(build_text('string1', 'en'))
        expect(translations[1].result).to eq(build_text('result2', 'de'))
      end
    end
  end

  def mock_languages
    # override to set up languages request
  end

  def mock_translation(_provider, _strings, _from, _to, _results)
    # override to set up translation requests
  end

  def create_instance
    # override to create a provider instance
    described_class.new
  end
end
