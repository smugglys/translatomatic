RSpec.describe Translatomatic::I18n do

  KEY_ERROR = "cli.error"
  EXPECTED_TEXT = "An error has occurred"

  it "should retrieve strings from the dictionaries" do
    expect(t(KEY_ERROR, locale: "en")).to eq(EXPECTED_TEXT)
  end

  it "should default to english for untranslated locales" do
    locale = "tlh-KX" # klingon
    expect(t(KEY_ERROR, locale: locale)).to eq(EXPECTED_TEXT)
  end

  private

  def t(key, options)
    described_class.t(key, options)
  end
end
