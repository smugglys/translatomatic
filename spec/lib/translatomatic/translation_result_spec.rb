RSpec.describe Translatomatic::TranslationResult do

  let(:locale_en) { locale('en') }
  let(:locale_de) { locale('de') }
  let(:locale_fr) { locale('fr') }
  let(:locale_ja) { locale('ja') }

    it "creates a result object" do
      result = create_result({}, locale_en, locale_fr)
      expect(result).to be
    end

    it "updates strings from translator" do
      properties = { key1: "Yoghurt" }
      result = create_result(properties, locale_en, locale_fr)
      translations = create_translations(result.untranslated, %w{Yoplait})
      result.add_translations(translations)
      result.apply!
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
      translations = create_translations(untranslated, %w{Yoplait})
      result.add_translations(translations)
      result.apply!
      expect(result.untranslated).to be_empty
      expect(result.properties).to eq({ key1: "Yoplait", key2: "Yoplait" })
    end

    it "updates sentences" do
      input = "Sentence one. Sentence two."
      properties = { key1: input }
      result = create_result(properties, locale_en, locale_de)
      untranslated = result.untranslated
      expect(untranslated.length).to eq(2)
      translations = create_translations([untranslated.to_a[0]], ['Satz eins.'])
      result.add_translations(translations)
      result.apply!
      expect(result.properties[:key1]).to eq("Satz eins. Sentence two.")
    end

    it "updates long strings with shorter ones" do
      input = "Translates text files from one language to another.  The following file formats are currently supported:"
      output = ["変換テキストファイルから一言語ます。", "以下のファイル形式は現在サポートされているのは、"]
      properties = { key1: input }
      result = create_result(properties, locale_en, locale_ja)
      untranslated = result.untranslated
      translations = create_translations(untranslated.to_a, output)
      result.add_translations(translations)
      result.apply!
      #p result.properties
    end

  private

  def create_translations(from, to)
    from.zip(to).collect { |t1, t2| Translatomatic::Translation.new(t1, t2) }
  end

  def create_result(properties, from, to)
    file = Translatomatic::ResourceFile::Properties.new("dummy", locale: from)
    file.properties = properties
    Translatomatic::TranslationResult.new(file, to)
  end
end
