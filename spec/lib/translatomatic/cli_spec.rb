RSpec.describe Translatomatic::CLI do

  before(:each) do
    @cli = described_class.new
    @cli.options = { database_env: "test" }
  end

  it "translates a file" do
    Translatomatic::Model::Text.destroy_all unless database_disabled?
    path = create_tempfile("test.properties", "key = Beer")
    translator = test_translator
    expect(translator).to receive(:translate).and_return(["Bier"])
    @cli.translate(path.to_s, "de")
  end

  it "does not translate unsupported files" do
    path = create_tempfile("test.exe")
    translator = test_translator
    expect(translator).to_not receive(:translate)
    @cli.translate(path.to_s, "de")
  end

  it "lists available translators" do
    @cli.list
  end

  private

  def test_translator
    translator = double(:translator)
    allow(translator).to receive(:name).and_return("Test")
    allow(@cli).to receive(:select_translator).and_return(translator)
    translator
  end

end
