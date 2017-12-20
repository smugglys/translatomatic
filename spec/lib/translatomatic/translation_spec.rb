RSpec.describe Translatomatic::Translation do

  it "creates a translation object" do
    t = Translatomatic::Translation.new
    expect(t).to be
  end

  it "translates a properties file to a target language" do
    translator = double(:translator)
    expect(translator).to receive(:translate).and_return(["Bier"])
    contents = "key = Beer"
    path = create_tempfile("test.properties", contents)
    t = Translatomatic::Translation.new(translator: translator)
    target = t.translate(path, "de-DE")
    expect(target.path.basename.sub_ext('').to_s).to match(/_de-DE$/)
    expect(target.path.read).to eq("key = Bier\n")
  end

  it "works with equal source and target languages" do
    translator = double(:translator)
    expect(translator).to_not receive(:translate)
    t = described_class.new(translator: translator)
    properties = { key: "yoghurt" }
    result = t.translate_properties(properties, "en", "en-US")
    expect(result[:key]).to eq("yoghurt")
  end

  it "uses existing translations from the database" do
    # add a translation to the database
    en_text = create_text(value: "yoghurt", locale: "en")
    fr_text = create_text(value: "yoplait", locale: "fr", from_text: en_text)

    translator = double(:translator)
    expect(translator).to_not receive(:translate)
    t = described_class.new(translator: translator)
    properties = { key: "yoghurt" }
    result = t.translate_properties(properties, "en", "fr")
    expect(result).to be
    expect(result[:key]).to eq("yoplait")
  end

  it "saves translations to the database" do
    translator = double(:translator)
    expect(translator).to receive(:translate).and_return(["Bier"])
    t = described_class.new(translator: translator)
    properties = { key: "Beer" }
    Translatomatic::Model::Text.delete_all
    expect {
      result = t.translate_properties(properties, "en", "de")
      # should add original and translated text to database (2 records)
    }.to change(Translatomatic::Model::Text, :count).by(2)
  end

  private

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
