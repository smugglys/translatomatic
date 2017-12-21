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
    @cli.translate(path, "de")
  end

  it "lists available translators" do
    @cli.translators
  end

end
