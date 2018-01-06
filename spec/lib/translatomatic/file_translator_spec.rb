RSpec.describe Translatomatic::FileTranslator do

  let(:locale_en) { locale("en") }
  let(:locale_de) { locale("de") }

  context :new do
    it "creates a new instance" do
      translator = TestTranslator.new("test")
      t = create_file_translator(translator: translator)
      expect(t).to be
    end

    it "resolves a translator by name" do
      t = create_file_translator(translator: "Yandex", yandex_api_key: "123")
      expect(t).to be
    end

    it "allows specifying multiple translators" do
      t = create_file_translator(translator: ["Microsoft", "Yandex"],
        yandex_api_key: "123", microsoft_api_key: "456")
      expect(t).to be
    end
  end

  context :translate_to_file do
    it "translates a properties file to a target language" do
      translator = TestTranslator.new("Bier")
      contents = "key = Beer"
      path = create_tempfile("test.properties", contents)
      t = create_file_translator(translator: translator)
      target = t.translate_to_file(path, "de-DE")
      expect(target.path.basename.sub_ext('').to_s).to match(/_de-DE$/)
      expect(strip_comments(target.path.read)).to eq("key = Bier\n")
    end

    it "doesn't write files or translate strings when using dry run" do
      translator = test_translator
      expect(translator).to_not receive(:translate)
      path = create_tempfile("test.properties", "key = Beer")
      t = create_file_translator(translator: translator, dry_run: true)
      target = t.translate_to_file(path, "de-DE")
      expect(target.path).to_not exist
    end
  end

  context :translate do
    it "works with equal source and target languages" do
      translator = test_translator
      expect(translator).to_not receive(:translate)
      t = create_file_translator(translator: translator)
      file = create_test_file
      file.properties = { key: "yoghurt" }
      result = t.translate(file, "en-US")
      expect(result.properties[:key]).to eq("yoghurt")
    end

    it "translates multiple sentences separately" do
      translator = test_translator
      expect(translator).to receive(:translate).
      with(["Sentence one.", "Sentence two."], locale_en, locale_de).
      and_return(["Satz eins.", "Satz zwei."])

      t = create_file_translator(translator: translator)
      file = create_test_file
      file.properties = { key: "Sentence one. Sentence two." }
      result = t.translate(file, "de")
      expect(result.properties[:key]).to eq("Satz eins. Satz zwei.")
    end

    it "uses multiple translators" do
      translator1 = test_translator
      translator2 = test_translator
      t = create_file_translator(translator: [translator1, translator2])
      file = create_test_file
      file.properties = { key: "yoghurt" }
      t.translate(file, "en-US")
    end

    it "uses existing translations from the database" do
      skip if database_disabled?

      translator = test_translator

      # add a translation to the database
      en_text = create_text(value: "yoghurt", locale: "en")
      create_text(value: "yoplait", locale: "fr",
        from_text: en_text, translator: translator.name)

      expect(translator).to_not receive(:translate)
      t = create_file_translator(translator: translator)
      file = create_test_file
      file.properties = { key: "yoghurt" }
      result = t.translate(file, "fr")
      expect(result).to be
      expect(result.properties[:key]).to eq("yoplait")
    end

    it "saves translations to the database" do
      skip if database_disabled?

      translator = test_translator("Bier")
      t = create_file_translator(translator: translator)
      file = create_test_file
      file.properties = { key: "Beer" }
      Translatomatic::Model::Text.destroy_all
      expect {
        t.translate(file, "de")
        # should add original and translated text to database (2 records)
      }.to change(Translatomatic::Model::Text, :count).by(2)
    end
  end

  # test preservation of interpolation variable names
  Translatomatic::ResourceFile.types.each do |type|
    type_string = type.to_s.demodulize
    if type.supports_variable_interpolation?

      describe "#{type_string} files variable interpolation" do
        it "preserves variable names" do
          file = create_test_file(type)
          original_variable = file.create_variable("var1")
          translated_variable = file.create_variable("translated_var1")
          file.properties = {
            key1: "rah #{original_variable} rah"
          }
          translated_text = "zomg #{translated_variable} zomg"
          translator = test_translator(translated_text)
          t = create_file_translator(translator: translator, use_database: false)
          t.translate(file, "de")
          expected_result = "zomg #{original_variable} zomg"
          expect(file.properties[:key1]).to eq(expected_result)
        end

        it "rejects translations with malformed variable names" do
          file = create_test_file(type)
          translator = setup_failed_variable_restore(file)
          t = create_file_translator(translator: translator, use_database: false)
          t.translate(file, "de")
          expect(file.properties[:key1]).to eq(nil)
        end

        it "does not save rejected translations to the database" do
          skip if database_disabled?

          file = create_test_file(type)
          translator = setup_failed_variable_restore(file)
          t = create_file_translator(translator: translator)
          expect {
            t.translate(file, "de")
          }.to_not change(Translatomatic::Model::Text, :count)
        end

        private

        def setup_failed_variable_restore(file)
          original_variable = file.create_variable("var1")
          translated_variable = "MUNGED"
          file.properties = {
            key1: "rah #{original_variable} rah"
          }
          translated_text = "zomg #{translated_variable} zomg"
          test_translator(translated_text)
        end
      end
    end
  end

  private

  def create_file_translator(options = {})
    Translatomatic::FileTranslator.new(options)
  end

  def create_test_file(klass = Translatomatic::ResourceFile::Properties)
    klass.new
  end

  def strip_comments(text)
    text.gsub(/^#.*\n/, '')
  end

  def test_translator(mapping = {})
    translator = TestTranslator.new(mapping)
    translator
  end

  def create_text(attributes)
    if attributes[:locale].kind_of?(String)
      attributes[:locale] = create_locale(attributes[:locale])
    end
    Translatomatic::Model::Text.create!(attributes)
  end

  def create_locale(tag)
    Translatomatic::Model::Locale.from_tag(tag)
  end
end