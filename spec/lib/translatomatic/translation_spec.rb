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
    targets = t.translate(path, "de-DE")
    target = targets.first
    expect(targets.length).to eq(1)
    expect(target.path.basename.sub_ext('').to_s).to match(/_de-DE$/)
    expect(target.path.read).to eq("key = Bier\n")
  end

  it "works with equal source and target locales" do
    translator = double(:translator)
    expect(translator).to_not receive(:translate)
    path = create_tempfile("test.properties", "key = Beer")
    t = Translatomatic::Translation.new(translator: translator)
    targets = t.translate(path, "en")
  end

  it "uses existing translations from the database" do
    # add a translation to the database
    en_locale = create_locale("fr")
    fr_locale = create_locale("en")
    en_text = create_text(value: "yoghurt", locale: en_locale)
    fr_text = create_text(value: "yoplait", locale: fr_locale, from_text: en_text)

    translator = double(:translator)
    expect(translator).to_not receive(:translate)
    t = described_class.new(translator: translator)
    properties = { key: "yoghurt" }
    result = t.translate_properties(properties, en_locale, fr_locale)
    expect(result).to be
    expect(result[:key]).to eq("yoplait")
  end

  private

  def create_text(attributes)
    Translatomatic::Model::Text.create!(attributes)
  end

  def create_locale(tag)
    Translatomatic::Model::Locale.from_tag(tag)
  end
end
