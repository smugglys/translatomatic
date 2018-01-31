RSpec.describe Translatomatic::Locale do
  it 'tests for equal locale objects' do
    locale1 = build_locale('en')
    locale2 = build_locale('en')
    expect(locale1).to eq(locale2)
    expect(locale1 == locale2).to be_truthy
  end
end