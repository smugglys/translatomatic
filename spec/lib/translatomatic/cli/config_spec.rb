RSpec.describe Translatomatic::CLI::Config do
  let(:cli) { Translatomatic::CLI::Config.new }
  let(:config) { Translatomatic::Config.instance }

  KEY_CLI_TEST = "target_locales"

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

  context :remove do
    it "removes a configuration option" do
      key = KEY_CLI_TEST
      cli.set(key, "de")
      cli.remove(key)
      expect(config.include?(key)).to be_falsey
    end
  end

  context :list do
    it "lists configuration options" do
      cli.list
    end
  end

  private

  def add_cli_options(options = {})
    @cli.options = @cli.options.merge(options)
  end

end
