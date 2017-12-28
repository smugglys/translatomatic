RSpec.describe Translatomatic::TranslationResult do

  let(:locale_en) { locale('en') }
  let(:locale_de) { locale('de') }
  let(:locale_fr) { locale('fr') }

  context :new do
    it "creates a result object" do
      result = create_result({}, locale_en, locale_fr)
      expect(result).to be
    end
  end

  context :update_strings do
    it "updates strings from translator" do
      properties = { key1: "Yoghurt" }
      result = create_result(properties, locale_en, locale_fr)
      result.update_strings(result.untranslated, %w{Yoplait})
      expect(result.untranslated).to be_empty
      expect(result.properties[:key1]).to eq("Yoplait")
    end

    it "works with duplicate values" do
      properties = { key1: "Yoghurt", key2: "Yoghurt" }
      result = create_result(properties, locale_en, locale_fr)
      # singular Yoghurt
      untranslated = result.untranslated
      expect(untranslated.length).to eq(1)
      expect(untranslated.to_a[0].to_s).to eq("Yoghurt")
      result.update_strings(untranslated, %w{Yoplait})
      expect(result.untranslated).to be_empty
      expect(result.properties).to eq({ key1: "Yoplait", key2: "Yoplait" })
    end

    it "updates sentences" do
      input = "Sentence one. Sentence two."
      properties = { key1: input }
      result = create_result(properties, locale_en, locale_de)
      untranslated = result.untranslated
      expect(untranslated.length).to eq(2)
      result.update_strings([untranslated.to_a[0]], ['Satz eins.'])
      expect(result.properties[:key1]).to eq("Satz eins. Sentence two.")
    end
  end

  private

  def create_result(properties, from, to)
    Translatomatic::TranslationResult.new(properties, from, to)
  end
end
