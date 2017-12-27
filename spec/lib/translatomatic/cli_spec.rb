RSpec.describe Translatomatic::CLI do

  before(:each) do
    @cli = Translatomatic::CLI.new
    @cli.options = { database_env: "test" }
  end

  context :translate do
    it "translates a file" do
      Translatomatic::Model::Text.destroy_all unless database_disabled?
      path = create_tempfile("test.properties", "key = Beer")
      translator = test_translator
      expect(translator).to receive(:translate).and_return(["Bier"])
      add_cli_options(use_database: false, wank: true)
      @cli.translate(path.to_s, "de")
    end

    it "does not translate unsupported files" do
      path = create_tempfile("test.exe")
      translator = test_translator
      expect(translator).to_not receive(:translate)
      add_cli_options(use_database: false)  # don't use database results
      @cli.translate(path.to_s, "de")
    end

    it "prompts user to select translator if there are multiple available" do
      # create two translators
      translator1 = double(:translator)
      allow(translator1).to receive(:name).and_return("Translator 1")
      translator2 = double(:translator2)
      allow(translator2).to receive(:name).and_return("Translator 2")

      expect(translator2).to receive(:translate).and_return(["Bier"])

      allow(Translatomatic::Translator).to receive(:available).
        and_return([translator1, translator2])

      expect(@cli).to receive(:ask).and_return(2)  # select translator 2

      path = create_tempfile("test.properties", "key = Beer")
      add_cli_options(use_database: false)  # don't use database results
      @cli.translate(path.to_s, "de")
    end

    it "shares translations" do
      path = create_tempfile("test.properties", "key = Beer")
      translator = test_translator
      expect(translator).to receive(:translate).and_return(["Bier"])
      expect(translator).to receive(:upload)
      add_cli_options(share: true)
      @cli.translate(path.to_s, "de")
    end
  end

  context :list do
    it "lists available translators" do
      @cli.list
    end
  end

  context :display do
    it "displays values from a resource bundle" do
      @cli.display(fixture_path("test.properties"), "property1")
    end
  end

  context :version do
    it "shows version number" do
      @cli.version
    end
  end

  context :strings do
    it "displays strings from a resource file" do
      @cli.strings(fixture_path("test.properties"))
    end
  end

  private

  def add_cli_options(options = {})
    @cli.options = @cli.options.merge(options)
  end

  def test_translator
    translator = double(:translator)
    allow(translator).to receive(:name).and_return("Translator")
    allow(translator).to receive(:listener=)
    allow(Translatomatic::Translator).to receive(:available).and_return([translator])
    translator
  end

end
