RSpec.describe Translatomatic::FileTranslator do
  let(:locale_en) { locale('en') }
  let(:locale_de) { locale('de') }

  context '#new' do
    it 'creates a new instance' do
      provider = TestProvider.new('test')
      t = create_file_translator(provider: provider)
      expect(t).to be
    end

    it 'resolves a provider by name' do
      t = create_file_translator(provider: 'Yandex', yandex_api_key: '123')
      expect(t).to be
    end

    it 'allows specifying multiple providers' do
      t = create_file_translator(provider: %w[Microsoft Yandex],
                                 yandex_api_key: '123', microsoft_api_key: '456')
      expect(t).to be
    end
  end

  context '#translate_to_file' do
    it 'translates a properties file to a target language' do
      provider = TestProvider.new('Bier')
      path = create_tempfile('test.properties', 'key = Beer')
      file = Translatomatic::ResourceFile.load(path, locale: "en")
      t = create_file_translator(provider: provider)
      target = t.translate_to_file(file, 'de-DE')
      expect(target.path.basename.sub_ext('').to_s).to match(/_de-DE$/)
      expect(strip_comments(target.path.read)).to eq("key = Bier\n")
    end

    it "doesn't write files or translate strings when using dry run" do
      provider = test_provider
      expect(provider).to_not receive(:translate)
      path = create_tempfile('test.properties', 'key = Beer')
      file = Translatomatic::ResourceFile.load(path, locale: "en")
      t = create_file_translator(provider: provider, dry_run: true)
      target = t.translate_to_file(file, 'de-DE')
      expect(target.path).to_not exist
    end

    it 'writes to the same file with the in-place option' do
      provider = TestProvider.new('Bier')
      path = create_tempfile('test.properties', 'key = Beer')
      file = Translatomatic::ResourceFile.load(path, locale: "en")
      t = create_file_translator(provider: provider, in_place: true)
      target = t.translate_to_file(file, 'de')
      expect(target.path).to eq(file.path)
      file = Translatomatic::ResourceFile.load(file.path, locale: "de")
      expect(file.get('key')).to eq('Bier')
    end
  end

  context '#translate' do
    it 'works with equal source and target languages' do
      provider = test_provider
      expect(provider).to_not receive(:translate)
      t = create_file_translator(provider: provider)
      file = create_test_file
      file.properties = { key: 'yoghurt' }
      result = t.translate(file, 'en-US')
      expect(result.properties[:key]).to eq('yoghurt')
    end

    it 'translates keys with duplicate values' do
      mapping = {
        'Yoghurt' => 'Yoplait',
      }
      provider = test_provider(mapping)
      t = create_file_translator(provider: provider)
      file = create_test_file
      file.properties = {
        key1: 'Yoghurt',
        key2: 'Yoghurt'
      }
      result = t.translate(file, 'fr')
      expect(result.properties).to eq(key1: 'Yoplait', key2: 'Yoplait')
    end

    it 'translates multiple sentences separately' do
      mapping = {
        'Sentence one.' => 'Satz eins.',
        'Sentence two.' => 'Satz zwei.'
      }
      provider = test_provider(mapping)
      t = create_file_translator(provider: provider)
      file = create_test_file
      file.properties = { key: 'Sentence one. Sentence two.' }
      result = t.translate(file, 'de')
      expect(result.properties[:key]).to eq('Satz eins. Satz zwei.')
    end

    # TODO: newlines aren't being preserved in text files because we
    # are splitting on sentence boundaries and some providers don't
    # preserve newlines. could split on newline boundaries optionally?
    #     it "preserves newlines" do
    #       provider = test_provider
    #
    #       t = create_file_translator(provider: provider)
    #       file = create_test_file
    #       file.properties = { key: "- value 1\n- value 2" }
    #       result = t.translate(file, "de")
    #       expect(result.properties[:key]).to eq("- Wert 1\n-Wert 2")
    #     end

    it 'uses multiple providers' do
      provider1 = test_provider
      provider2 = test_provider
      t = create_file_translator(provider: [provider1, provider2])
      file = create_test_file
      file.properties = { key: 'yoghurt' }
      t.translate(file, 'en-US')
    end

    it 'uses existing translations from the database' do
      skip if database_disabled?

      provider = TestProvider.new
      expect(provider).to_not receive(:translate)

      # add a translation to the database
      en_text = create_text(value: 'chicken', locale: 'en')
      create_text(value: 'buckerk', locale: 'de',
                  from_text: en_text, provider: provider.name)

      t = create_file_translator(provider: provider)
      file = create_test_file
      file.properties = { key: 'chicken' }
      result = t.translate(file, 'de')
      expect(result).to be
      expect(result.properties[:key]).to eq('buckerk')
    end

    # exercises bug in translation result: "index 30 out of string".
    # caused by calling update_strings multiple times without updating
    # substring offsets.
    it 'uses translations from database and provider' do
      skip if database_disabled?

      provider = test_provider('hello.' => 'hallo.')

      # add a translation to the database
      en_text = create_text(value: 'this is a very long sentence.', locale: 'en')
      create_text(value: 'short!', locale: 'de',
                  from_text: en_text, provider: provider.name)

      t = create_file_translator(provider: provider)
      file = create_test_file
      file.properties = { key: 'this is a very long sentence. hello.' }
      result = t.translate(file, 'de')
      expect(result).to be
      expect(result.properties[:key]).to eq('short! hallo.')
    end

    it 'saves translations to the database' do
      skip if database_disabled?

      provider = test_provider('Bier')
      t = create_file_translator(provider: provider)
      file = create_test_file
      file.properties = { key: 'Beer' }
      Translatomatic::Model::Text.destroy_all
      expect do
        t.translate(file, 'de')
        # should add original and translated text to database (2 records)
      end.to change(Translatomatic::Model::Text, :count).by(2)
    end
  end

  # test preservation of interpolation variable names
  Translatomatic::ResourceFile.types.each do |type|
    type_string = type.to_s.demodulize
    next unless type.supports_variable_interpolation?

    describe "#{type_string} file variable interpolation" do
      it 'preserves variable names' do
        file = create_test_file(type)
        original_variable = file.create_variable('var1')
        translated_variable = file.create_variable('translated_var1')
        file.properties = {
          key1: "rah #{original_variable} rah"
        }
        translated_text = "zomg #{translated_variable} zomg"
        provider = test_provider(translated_text)
        t = create_file_translator(provider: provider, no_database: true)
        t.translate(file, 'de')
        expected_result = "zomg #{original_variable} zomg"
        expect(file.properties[:key1]).to eq(expected_result)
      end

      it 'rejects translations with malformed variable names' do
        file = create_test_file(type)
        provider = setup_failed_variable_restore(file)
        t = create_file_translator(provider: provider, no_database: true)
        t.translate(file, 'de')
        expect(file.properties[:key1]).to eq(nil)
      end

      it 'does not save rejected translations to the database' do
        skip if database_disabled?

        file = create_test_file(type)
        provider = setup_failed_variable_restore(file)
        t = create_file_translator(provider: provider)
        expect do
          t.translate(file, 'de')
        end.to_not change(Translatomatic::Model::Text, :count)
      end

      private

      def setup_failed_variable_restore(file)
        original_variable = file.create_variable('var1')
        translated_variable = 'MUNGED'
        file.properties = {
          key1: "rah #{original_variable} rah"
        }
        translated_text = "zomg #{translated_variable} zomg"
        test_provider(translated_text)
      end
    end
  end

  private

  def create_file_translator(options = {})
    Translatomatic::FileTranslator.new(options)
  end

  def create_test_file(klass = Translatomatic::ResourceFile::Properties)
    klass.new(nil, locale: "en")
  end

  def strip_comments(text)
    text.gsub(/^#.*\n/, '')
  end

  def test_provider(mapping = {})
    TestProvider.new(mapping)
  end

  def create_text(attributes)
    if attributes[:locale].is_a?(String)
      attributes[:locale] = create_locale(attributes[:locale])
    end
    Translatomatic::Model::Text.create!(attributes)
  end

  def create_locale(tag)
    Translatomatic::Model::Locale.from_tag(tag)
  end
end
