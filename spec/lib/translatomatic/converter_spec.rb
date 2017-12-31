RSpec.describe Translatomatic::Converter do
  include Translatomatic::Util

  let(:locale_en) { locale("en") }
  let(:locale_de) { locale("de") }

  class TestTranslator < Translatomatic::Translator::Base
    def initialize(result)
      @mapping = result
    end

    def perform_translate(strings, from, to)
      if @mapping.kind_of?(Hash)
        strings.collect { |i| @mapping[i] }
      else
        strings.collect { |i| @mapping }
      end
    end
  end

  it "creates a new instance" do
    translator = TestTranslator.new("test")
    t = described_class.new(translator: translator)
    expect(t).to be
  end

  it "requires a translator" do
    expect {
      described_class.new
    }.to raise_error(t("converter.translator_required"))
  end

  it "translates a properties file to a target language" do
    translator = TestTranslator.new("Bier")
    contents = "key = Beer"
    path = create_tempfile("test.properties", contents)
    t = described_class.new(translator: translator)
    target = t.translate_to_file(path, "de-DE")
    expect(target.path.basename.sub_ext('').to_s).to match(/_de-DE$/)
    expect(strip_comments(target.path.read)).to eq("key = Bier\n")
  end

  it "doesn't write files or translate strings when using dry run" do
    translator = mock_translator
    expect(translator).to_not receive(:translate)
    path = create_tempfile("test.properties", "key = Beer")
    t = described_class.new(translator: translator, dry_run: true)
    target = t.translate_to_file(path, "de-DE")
    expect(target.path).to_not exist
  end

  it "works with equal source and target languages" do
    translator = mock_translator
    expect(translator).to_not receive(:translate)
    t = described_class.new(translator: translator)
    properties = { key: "yoghurt" }
    result = t.translate_properties(properties, "en", "en-US")
    expect(result.properties[:key]).to eq("yoghurt")
  end

  it "translates multiple sentences separately" do
    translator = mock_translator
    expect(translator).to receive(:translate).
      with(["Sentence one.", "Sentence two."], locale_en, locale_de).
      and_return(["Satz eins.", "Satz zwei."])

    t = described_class.new(translator: translator)
    properties = { key: "Sentence one. Sentence two." }
    result = t.translate_properties(properties, "en", "de")
    expect(result.properties[:key]).to eq("Satz eins. Satz zwei.")
  end

  it "uses existing translations from the database" do
    skip if database_disabled?

    # add a translation to the database
    en_text = create_text(value: "yoghurt", locale: "en")
    create_text(value: "yoplait", locale: "fr", from_text: en_text)

    translator = mock_translator
    expect(translator).to_not receive(:translate)
    t = described_class.new(translator: translator)
    properties = { key: "yoghurt" }
    result = t.translate_properties(properties, "en", "fr")
    expect(result).to be
    expect(result.properties[:key]).to eq("yoplait")
  end

  it "saves translations to the database" do
    skip if database_disabled?

    translator = TestTranslator.new("Bier")
    t = described_class.new(translator: translator)
    properties = { key: "Beer" }
    Translatomatic::Model::Text.destroy_all
    expect {
      t.translate_properties(properties, "en", "de")
      # should add original and translated text to database (2 records)
    }.to change(Translatomatic::Model::Text, :count).by(2)
  end

  # test preservation of interpolation variable names
  Translatomatic::ResourceFile.modules.each do |mod|
    file = mod.new("dummy_path", "en")
    described = described_class
    if file.supports_variable_interpolation?
      describe "#{mod.name.demodulize} files variable interpolation" do
        it "preserves variable names" do
          original_variable = file.create_variable("var1")
          translated_variable = file.create_variable("translated_var1")
          file.properties = {
            key1: "rah #{original_variable} rah"
          }
          translated_text = "zomg #{translated_variable} zomg"
          translator = TestTranslator.new(translated_text)
          t = described.new(translator: translator, use_database: false)
          t.translate(file, "de")
          expected_result = "zomg #{original_variable} zomg"
          expect(file.properties[:key1]).to eq(expected_result)
        end

        it "rejects translations with malformed variable names" do
          original_variable = file.create_variable("var1")
          translated_variable = "MUNGED"
          file.properties = {
            key1: "rah #{original_variable} rah"
          }
          translated_text = "zomg #{translated_variable} zomg"
          translator = TestTranslator.new(translated_text)
          t = described.new(translator: translator, use_database: false)
          t.translate(file, "de")
          expect(file.properties[:key1]).to eq(nil)
        end
      end
    end
  end

  private

  def strip_comments(text)
    text.gsub(/^#.*\n/, '')
  end

  def mock_translator
    translator = double(:translator)
    allow(translator).to receive(:name).and_return("MockTranslator")
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
