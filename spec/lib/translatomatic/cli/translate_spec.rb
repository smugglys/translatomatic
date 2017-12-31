RSpec.describe Translatomatic::CLI::Translate do

  before(:each) do
    @cli = Translatomatic::CLI::Translate.new
    @cli.options = { database_env: "test" }
  end

  context :string do
    it "translates a string" do
      translator = test_translator
      expect(translator).to receive(:translate).and_return(["Bier"])
      add_cli_options(use_database: false)
      @cli.string("Beer", "de")
    end
  end

  context :file do
    it "translates a file" do
      path = create_tempfile("test.properties", "key = Beer")
      translator = test_translator
      expect(translator).to receive(:translate).and_return(["Bier"])
      add_cli_options(use_database: false, wank: true)
      @cli.file(path.to_s, "de")
    end

    it "does not translate unsupported files" do
      path = create_tempfile("test.exe")
      translator = test_translator
      expect(translator).to_not receive(:translate)
      add_cli_options(use_database: false)  # don't use database results
      @cli.file(path.to_s, "de")
    end

    it "prompts user to select translator if there are multiple available" do
      # create two translators
      translator1 = test_translator("Translator 1")
      translator2 = test_translator("Translator 2")
      expect(translator2).to receive(:translate).and_return(["Bier"])

      allow(Translatomatic::Translator).to receive(:available).
        and_return([translator1, translator2])

      expect(@cli).to receive(:ask).and_return(2)  # select translator 2

      path = create_tempfile("test.properties", "key = Beer")
      add_cli_options(use_database: false)  # don't use database results
      @cli.file(path.to_s, "de")
    end

    it "shares translations" do
      # translations are shared from database records
      skip if database_disabled?

      path = create_tempfile("test.properties", "key = Beer")
      translator = test_translator
      expect(translator).to receive(:translate).and_return(["Bier"])
      expect(translator).to receive(:upload)
      add_cli_options(share: true)
      @cli.file(path.to_s, "de")
    end
  end

  private

  def add_cli_options(options = {})
    @cli.options = @cli.options.merge(options)
  end

  def test_translator(name = nil)
    translator = double(:translator)
    allow(translator).to receive(:name).and_return("Translator")
    allow(translator).to receive(:listener=)
    allow(translator).to receive(:name).and_return(name)
    allow(Translatomatic::Translator).to receive(:available).and_return([translator])
    translator
  end

end
