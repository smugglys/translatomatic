RSpec.describe Translatomatic::TranslationResult do
  include Translatomatic::Util

  before(:all) do
    @locale_en = parse_locale("en")
    @locale_fr = parse_locale("fr")
  end

  it "creates a result object" do
    result = described_class.new({}, @locale_en, @locale_fr)
    expect(result).to be
  end

  it "updates strings from translator" do
    properties = { key1: "Yoghurt" }
    result = described_class.new(properties, @locale_en, @locale_fr)
    result.update_strings(%w{Yoghurt}, %w{Yoplait})
    expect(result.untranslated).to be_empty
    expect(result.properties[:key1]).to eq("Yoplait")
  end

  it "works with duplicate values" do
    properties = { key1: "Yoghurt", key2: "Yoghurt" }
    result = described_class.new(properties, @locale_en, @locale_fr)
    # singular Yoghurt
    expect(result.untranslated.to_a).to eq(%w{Yoghurt})
    result.update_strings(%w{Yoghurt}, %w{Yoplait})
    expect(result.untranslated).to be_empty
    expect(result.properties).to eq({ key1: "Yoplait", key2: "Yoplait" })
  end
end
