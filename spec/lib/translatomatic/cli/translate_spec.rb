RSpec.describe Translatomatic::CLI::Translate do
  let(:config) { Translatomatic.config }

  before(:each) do
    config.unset(:provider)
    @cli = Translatomatic::CLI::Translate.new
    @cli.options = { database_env: 'test', source_locale: "en" }
  end

  context :help do
    it 'displays usage' do
      # exercise some code that displays usage text
      @cli.help('file')
    end
  end

  context :string do
    it 'translates a string' do
      test_provider('Bier')
      add_cli_options(no_database: true, target_locales: 'de')
      @cli.build_text('Beer')
    end

    it 'uses command line options in preference to configuration' do
      config.set(:provider, 'Yandex,Microsoft')
      add_cli_options(provider: 'Google', target_locales: 'de')
      expect(Translatomatic::Provider).to receive(:find)
        .with('Google').and_return(TestProvider)
      @cli.build_text('Beer')
    end
  end

  context :file do
    it 'translates a file' do
      path = create_tempfile('test.properties', 'key = Beer')
      test_provider('Bier')
      add_cli_options(no_database: true, target_locales: 'de')
      @cli.file(path.to_s)
    end

    it 'does not translate unsupported files' do
      path = create_tempfile('test.exe')
      provider = test_provider
      expect(provider).to_not receive(:translate)
      # don't use database results
      add_cli_options(no_database: true, target_locales: 'de')
      expect do
        @cli.file(path.to_s)
      end.to raise_exception(t('file.unsupported', file: path))
    end

    it 'uses all available providers' do
      # create two providers
      provider1 = test_provider
      provider2 = test_provider

      allow(Translatomatic::Provider).to receive(:available)
        .and_return([provider1, provider2])

      path = create_tempfile('test.properties', 'key = Beer')
      # don't use database results
      add_cli_options(no_database: true, target_locales: 'de')
      @cli.file(path.to_s)
    end

    it 'shares translations' do
      skip 'not implmeneted yet'
      # translations are shared from database records
      skip if database_disabled?

      path = create_tempfile('test.properties', 'key = Beer')
      provider = test_provider('Bier')
      expect(provider).to receive(:upload)
      add_cli_options(share: true, target_locales: 'de')
      @cli.file(path.to_s)
    end

    it 'requires target build_locale(s)' do
      path = create_tempfile('test.properties', 'key = Beer')
      provider = test_provider
      expect(provider).to_not receive(:translate)
      # don't use database results
      expect do
        @cli.file(path.to_s)
      end.to raise_exception(t('cli.locales_required'))
    end
  end

  private

  def add_cli_options(options = {})
    @cli.options = @cli.options.merge(options)
  end

  def test_provider(mapping = {})
    provider = TestProvider.new(mapping)
    allow(Translatomatic::Provider).to receive(:available).and_return([provider])
    provider
  end
end
