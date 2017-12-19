RSpec.describe Translatomatic::Model::Text do

  before(:all) do
    @locale_en = Translatomatic::Model::Locale.find_or_create_by(language: :en)
    @locale_fr = Translatomatic::Model::Locale.find_or_create_by(language: :fr)
  end

  it "creates a text record" do
    text = described_class.new
    text.value = "this is some text"
    text.locale = @locale_en
    expect(text.save).to be_truthy
  end

  it "creates a text record translated from another record" do
    text = described_class.new
    text.value = "this is some text"
    text.locale = @locale_en
    expect(text.save).to be_truthy

    translated = described_class.new
    translated.value = "la la la french"
    translated.locale = @locale_fr
    translated.from_text = text
    expect(translated.save).to be_truthy

    text.reload
    expect(text.translations).to include(translated)
  end

  it "requires a locale" do
    text = described_class.new
    text.value = "this is some text"
    text.locale = nil
    expect(text).to be_invalid
  end
end
