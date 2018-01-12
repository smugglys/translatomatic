RSpec.describe Translatomatic::Model::Text do
  include DatabaseHelpers

  before(:all) do
    skip if database_disabled?
    @locale_en = create_locale(language: :en)
    @locale_fr = create_locale(language: :fr)
    @locale_de = create_locale(language: :de)
  end

  it 'creates a text record' do
    skip if database_disabled?
    text = described_class.new
    text.value = 'this is some text'
    text.locale = @locale_en
    expect(text.save).to be_truthy
  end

  it 'creates a text record translated from another record' do
    skip if database_disabled?

    text = create_text(locale: @locale_en, value: 'Untranslated')
    translated = create_text(locale: @locale_fr, from_text: text, value: 'Translated')
    text.reload
    expect(text.translations).to include(translated)
  end

  it 'deletes dependent translations' do
    skip if database_disabled?
    t1 = create_text(value: 'ra', locale: @locale_en)
    create_text(value: 'ra ra', locale: @locale_fr, from_text: t1)
    create_text(value: 'ra ra ra', locale: @locale_de, from_text: t1)
    expect do
      t1.destroy
    end.to change(described_class, :count).by(-3)
  end

  it 'requires a locale' do
    text = described_class.new
    text.value = 'this is some text'
    text.locale = nil
    expect(text).to be_invalid
  end
end
