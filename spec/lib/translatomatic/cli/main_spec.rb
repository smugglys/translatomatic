RSpec.describe Translatomatic::CLI::Main do
  before(:each) do
    @cli = Translatomatic::CLI::Main.new
    @cli.options = { database_env: 'test' }
  end

  context :services do
    it 'lists available providers' do
      @cli.providers
    end
  end

  context :display do
    it 'displays values from a resource bundle' do
      @cli.display(fixture_path('test.properties'), 'property1')
    end

    it 'displays values and sentences from a resource bundle' do
      @cli.options = @cli.options.merge(sentences: true)
      @cli.display(fixture_path('test.properties'), 'property1')
    end

    it 'displays values from specified locales' do
      @cli.options = @cli.options.merge(locales: 'de')
      @cli.display(fixture_path('test.properties'), 'property1')
    end
  end

  context :version do
    it 'shows version number' do
      @cli.version
    end
  end

  context :convert do
    it 'converts resource files' do
      save_path = create_tempfile("test.strings")
      save_path.delete
      @cli.convert(fixture_path('test.properties'), save_path)
      expect(save_path).to exist
    end
  end

  context :strings do
    it 'displays strings from a resource file' do
      @cli.strings(fixture_path('test.properties'))
    end

    it 'displays strings from a resource file with debug enabled' do
      @cli.options = @cli.options.merge(debug: true)
      @cli.strings(fixture_path('test.properties'))
    end
  end
end
