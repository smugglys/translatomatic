RSpec.describe Translatomatic::CLI::Config do

  KEY_CLI_TEST = 'target_locales'.freeze
  KEY_CLI_BOOLEAN = 'no_wank'.freeze

  def config
    Translatomatic.config
  end

  before(:each) do
    reset_test_config
    @cli = Translatomatic::CLI::Config.new
    @cli_options = {}
    allow(@cli).to receive(:create_config) {
      use_test_config(runtime: @cli_options, keep_config: true)
    }
  end

  after(:all) do
    reset_test_config
  end

  context :set do
    it 'sets a configuration option' do
      @cli.set(KEY_CLI_TEST, 'value')
      expect(config.include?(KEY_CLI_TEST)).to be_truthy
    end

    it 'does not set an invalid configuration option' do
      key = 'invalid key'
      expect {
        @cli.set(key, 'value')
      }.to raise_error(t('config.invalid_key', key: key))
    end

    it 'sets a configuration option for a file' do
      expect {
        add_cli_options('for-file' => 'filename')
        @cli.set(KEY_CLI_TEST, 'value')
      }.to change {
        # should change the for file config
        config.get(KEY_CLI_TEST, for_file: 'filename')
      }.from([]).to(['value']).and not_change {
        # should not change config without the for_file
        config.get(KEY_CLI_TEST)
      }
    end
  end

  context :unset do
    it 'removes a configuration option' do
      key = KEY_CLI_TEST
      config.set(key, 'de')
      @cli.unset(key)
      expect(config.include?(key, location: :user)).to be_falsey
    end
  end

  describe :add do
    it 'adds a value to a list' do
      config.set(KEY_CLI_TEST, 'de')
      @cli.add(KEY_CLI_TEST, 'fr')
      expect(config.get(KEY_CLI_TEST)).to eq(%w[de fr])
    end

    it 'fails on non list types' do
      expect do
        @cli.add(KEY_CLI_BOOLEAN, true)
      end.to raise_error(t('config.non_array_key', key: KEY_CLI_BOOLEAN))
    end
  end

  describe :subtract do
    it 'removes a value from a list' do
      config.set(KEY_CLI_TEST, %w[de fr])
      @cli.subtract(KEY_CLI_TEST, 'fr')
      expect(config.get(KEY_CLI_TEST)).to eq(['de'])
    end

    it 'fails on non list types' do
      expect do
        @cli.add(KEY_CLI_BOOLEAN, true)
      end.to raise_error(t('config.non_array_key', key: KEY_CLI_BOOLEAN))
    end
  end

  context :list do
    it 'lists configuration options' do
      @cli.list
    end
  end

  context :describe do
    it 'describes configuration options' do
      @cli.describe
    end
  end

  private

  def add_cli_options(options = {})
    @cli_options.merge!(options)
    @cli.options = @cli_options
  end

end
