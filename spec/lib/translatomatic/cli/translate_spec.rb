RSpec.describe Translatomatic::CLI::Translate do
  let(:config) { Translatomatic.config }

  before(:each) do
    config.unset(:translator)
    @cli = Translatomatic::CLI::Translate.new
    @cli.options = { database_env: 'test', source_locale: "en" }
  end

  context :string do
    it 'translates a string' do
      translator = test_translator
      expect(translator).to receive(:translate).and_return(['Bier'])
      add_cli_options(no_database: true, target_locales: 'de')
      @cli.string('Beer')
    end

    it 'uses command line options in preference to configuration' do
      config.set(:translator, 'Yandex,Microsoft')
      add_cli_options(translator: 'Google', target_locales: 'de')
      expect(Translatomatic::Translator).to receive(:find)
        .with('Google').and_return(TestTranslator)
      @cli.string('Beer')
    end
  end

  context :file do
    it 'translates a file' do
      path = create_tempfile('test.properties', 'key = Beer')
      translator = test_translator
      expect(translator).to receive(:translate).and_return(['Bier'])
      add_cli_options(no_database: true, target_locales: 'de')
      @cli.file(path.to_s)
    end

    it 'does not translate unsupported files' do
      path = create_tempfile('test.exe')
      translator = test_translator
      expect(translator).to_not receive(:translate)
      # don't use database results
      add_cli_options(no_database: true, target_locales: 'de')
      expect do
        @cli.file(path.to_s)
      end.to raise_exception(t('file.unsupported', file: path))
    end

    it 'uses all available translators' do
      # create two translators
      translator1 = test_translator('Translator 1')
      translator2 = test_translator('Translator 2')
      expect(translator1).to receive(:translate).and_return(['Bier'])

      allow(Translatomatic::Translator).to receive(:available)
        .and_return([translator1, translator2])

      path = create_tempfile('test.properties', 'key = Beer')
      # don't use database results
      add_cli_options(no_database: true, target_locales: 'de')
      @cli.file(path.to_s)
    end

    it 'shares translations' do
      # translations are shared from database records
      skip if database_disabled?

      path = create_tempfile('test.properties', 'key = Beer')
      translator = test_translator
      expect(translator).to receive(:translate).and_return(['Bier'])
      expect(translator).to receive(:upload)
      add_cli_options(share: true, target_locales: 'de')
      @cli.file(path.to_s)
    end

    it 'requires target locale(s)' do
      path = create_tempfile('test.properties', 'key = Beer')
      translator = test_translator
      expect(translator).to_not receive(:translate)
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

  def test_translator(_name = nil)
    translator = TestTranslator.new
    allow(Translatomatic::Translator).to receive(:available).and_return([translator])
    translator
  end
end
