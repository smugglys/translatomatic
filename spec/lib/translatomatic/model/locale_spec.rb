RSpec.describe Translatomatic::Model::Locale do

  it "creates a locale record" do
    locale = described_class.new
    locale.language = "en"
    locale.save
    expect(described_class.count).to eq(1)
  end
end
