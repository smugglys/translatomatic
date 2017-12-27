RSpec.describe Translatomatic::TMX::Document do

  it "creates a new document" do
    doc = create_doc
    expect(doc).to be
  end

  it "converts document to xml" do
    xml = create_doc.to_xml
    expect(xml).to be
    expected_result = fixture_read("tmx/document.xml")
    expect(xml).to eq(expected_result)
  end

  it "creates valid tmx xml" do
    doc = create_doc
    dtd = fixture_path("tmx/tmx14.dtd")
    xml = doc.to_xml(dtd: dtd)
    expect(Translatomatic::TMX::Document.valid?(xml)).to be_truthy
  end

  it "creates a document from database translations" do
    skip unless Translatomatic::Database.enabled?
    locale_en = create_locale("en")
    locale_fr = create_locale("fr")
    text1 = FactoryBot.create(:text_model, locale: locale_en, value: "Yoghurt")
    text2 = FactoryBot.create(:text_model, locale: locale_fr, value: "Yoplait",
      from_text: text1, translator: "Test")
    tmx = described_class.from_texts([text1, text2])
    xml = tmx.to_xml
    expected_result = fixture_read("tmx/document.xml")
    expect(xml).to eq(expected_result)
  end

  private

  def create_locale(lang)
    Translatomatic::Model::Locale.find_or_create_by!(language: lang)
  end

  def create_doc
    source_locale = Translatomatic::Locale.parse("en")
    origin = "Test"
    locale_strings = [lstring("Yoghurt", "en"), lstring("Yoplait", "fr")]
    units = Translatomatic::TMX::TranslationUnit.new(locale_strings)
    Translatomatic::TMX::Document.new(units, source_locale, origin)
  end

  def lstring(string, locale)
    Translatomatic::TMX::LocaleString.new(string, locale)
  end
end
