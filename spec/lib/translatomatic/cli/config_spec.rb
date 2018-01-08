RSpec.describe Translatomatic::CLI::Config do
  let(:cli) { Translatomatic::CLI::Config.new }
  let(:config) { Translatomatic.config }

  KEY_CLI_TEST = "target_locales"
  KEY_CLI_DEBUG = "debug"

  before(:each) do
    # TODO: test with project level config also
    config.reset
    cli.options = { context: "user" }
  end

  context :set do
    it "sets a configuration option" do
      cli.set(KEY_CLI_TEST, "value")
      expect(config.include?(KEY_CLI_TEST)).to be_truthy
    end

    it "does not set an invalid configuration option" do
      key = "invalid key"
      expect {
        cli.set(key, "value")
      }.to raise_error(t("config.invalid_key", key: key))
    end
  end

  context :unset do
    it "removes a configuration option" do
      key = KEY_CLI_TEST
      cli.set(key, "de")
      cli.unset(key)
      expect(config.include?(key, :user)).to be_falsey
    end
  end

  describe :add do
    it "adds a value to a list" do
      cli.set(KEY_CLI_TEST, "de")
      cli.add(KEY_CLI_TEST, "fr")
      expect(config.get(KEY_CLI_TEST)).to eq(['de', 'fr'])
    end

    it "fails on non list types" do
      expect {
        cli.add(KEY_CLI_DEBUG, true)
      }.to raise_error(t("config.non_array_key", key: KEY_CLI_DEBUG))
    end
  end

  describe :subtract do
    it "removes a value from a list" do
      cli.set(KEY_CLI_TEST, ["de", "fr"])
      cli.subtract(KEY_CLI_TEST, "fr")
      expect(config.get(KEY_CLI_TEST)).to eq(['de'])
    end

    it "fails on non list types" do
      expect {
        cli.add(KEY_CLI_DEBUG, true)
      }.to raise_error(t("config.non_array_key", key: KEY_CLI_DEBUG))
    end
  end

  context :list do
    it "lists configuration options" do
      cli.list
    end
  end

  context :describe do
    it "describes configuration options" do
      cli.describe
    end
  end

  private

  def add_cli_options(options = {})
    @cli.options = @cli.options.merge(options)
  end

end
