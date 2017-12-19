RSpec.describe Translatomatic::Model::Locale do
  include Translatomatic::Util

  it "creates a locale record" do
    locale = described_class.new
    locale.language = "en"
    expect(locale.save).to be_truthy
  end

  it "creates a locale record from a string" do
    locale = described_class.from_tag("en-US")
    expect(locale).to be
    expect(locale.language).to eq("en")
    expect(locale.region).to eq("US")
  end

  it "creates a locale record from a tag" do
    tag = parse_locale("en-US")
    locale = described_class.from_tag(tag)
    expect(locale).to be
    expect(locale.language).to eq("en")
    expect(locale.region).to eq("US")
  end
end
