RSpec.describe Translatomatic::Model::Locale do

  it "creates a locale record" do
    skip if database_disabled?
    described_class.delete_all
    locale = described_class.new
    locale.language = "en"
    expect(locale).to be_valid
    expect(locale.save).to be_truthy
  end

  it "creates a locale record from a string" do
    skip if database_disabled?
    locale = described_class.from_tag("en-US")
    expect(locale).to be
    expect(locale.language).to eq("en")
    expect(locale.region).to eq("US")
  end

  it "creates a locale record from a tag" do
    skip if database_disabled?
    tag = Translatomatic::Locale.parse("en-US")
    locale = described_class.from_tag(tag)
    expect(locale).to be
    expect(locale.language).to eq("en")
    expect(locale.region).to eq("US")
  end
end
