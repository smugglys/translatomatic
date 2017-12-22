RSpec.describe Translatomatic::CLI do

  before(:each) do
    @cli = described_class.new
    @cli.options = { database_env: "test" }
  end

  it "translates a file" do
    Translatomatic::Model::Text.destroy_all
    path = create_tempfile("test.properties", "key = Beer")
    translator = double(:translator)
    expect(translator).to receive(:translate).and_return(["Bier"])
    @cli.options = @cli.options.merge(translator: translator)
    @cli.translate(path.to_s, "de")
  end

  it "does not translate unsupported files" do
    path = create_tempfile("test.exe")
    translator = double(:translator)
    expect(translator).to_not receive(:translate)
    @cli.options = @cli.options.merge(translator: translator)
    @cli.translate(path.to_s, "de")
  end

  it "lists available translators" do
    @cli.translators
  end

end
