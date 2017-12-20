RSpec.describe Translatomatic::CLI do

  before(:each) do
    @cli = described_class.new
  end

=begin
  it "translates all files" do
    @cli.translate
  end
=end

  it "translates a file" do
    path = create_tempfile("test.properties", "key = Beer")
    translator = double(:translator)
    expect(translator).to receive(:translate).and_return(["Bier"])
    @cli.options = { translator: translator }
    @cli.translate(path, "de")
  end

  it "lists available translators" do
    @cli.translators
  end

end
