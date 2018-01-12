RSpec.describe Translatomatic::TMX::Document do
  it 'creates a new document' do
    doc = create_doc
    expect(doc).to be
  end

  it 'converts document to xml' do
    xml = create_doc.to_xml
    expect(xml).to be
    expected_result = read_tmx_document('tmx/document.xml')
    expect(xml).to eq(expected_result)
  end

  it 'creates valid tmx xml' do
    doc = create_doc
    dtd = fixture_path('tmx/tmx14.dtd')
    xml = doc.to_xml(dtd: dtd)
    expect(Translatomatic::TMX::Document.valid?(xml)).to be_truthy
  end

  it 'creates a document from database translations' do
    skip if database_disabled?
    locale_en = create_locale(language: 'en')
    locale_fr = create_locale(language: 'fr')
    text1 = create_text(locale: locale_en, value: 'Yoghurt')
    text2 = create_text(
      locale: locale_fr, value: 'Yoplait',
      from_text: text1, translator: 'Test'
    )
    tmx = described_class.from_texts([text1, text2])
    xml = tmx.to_xml
    expected_result = read_tmx_document('tmx/document.xml')
    expect(xml).to eq(expected_result)
  end

  private

  include DatabaseHelpers

  def read_tmx_document(path)
    doc = fixture_read(path)
    doc.sub(/creationtoolversion=".*?"/, %(creationtoolversion="#{Translatomatic::VERSION}"))
  end

  def create_doc
    source_locale = Translatomatic::Locale.parse('en')
    strings = [string('Yoghurt', 'en'), string('Yoplait', 'fr')]
    units = Translatomatic::TMX::TranslationUnit.new(strings)
    Translatomatic::TMX::Document.new(units, source_locale)
  end
end
