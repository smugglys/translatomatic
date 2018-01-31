RSpec.describe Translatomatic::Config do
  KEY_LOCALES = 'target_locales'.freeze
  KEY_DB_CONFIG = 'database_config'.freeze
  KEY_BOOLEAN = 'no_wank'.freeze

  let(:config) { Translatomatic.config }

  before(:each) do
    config.reset
  end

  describe '#set' do
    it 'sets a configuration key' do
      config.set(KEY_LOCALES, 'de')
      expect(config.get(KEY_LOCALES)).to eq(['de'])
    end

    it 'sets a boolean setting' do
      config.set(KEY_BOOLEAN, 'true')
      expect(config.get(KEY_BOOLEAN)).to eq(true)
    end

    it 'writes configuration to file' do
      config.set(KEY_LOCALES, 'de')
      expect(config.get(KEY_LOCALES)).to eq(['de'])
      config.load
      expect(config.get(KEY_LOCALES)).to eq(['de'])
    end

    it 'does not set an invalid configuration option' do
      key = 'invalid key'
      expect do
        config.set(key, 'value ')
      end.to raise_error(t('config.invalid_key', key: key))
    end
  end

  describe '#unset' do
    it 'writes configuration to file' do
      config.set(KEY_LOCALES, 'de')
      expect(config.get(KEY_LOCALES)).to eq(['de'])
      config.unset(KEY_LOCALES)
      config.load
      expect(config.get(KEY_LOCALES)).to be_empty
    end

    it 'removes a boolean setting' do
      config.set(KEY_BOOLEAN, 'false')
      expect(config.get(KEY_BOOLEAN)).to eq(false)
      config.unset(KEY_BOOLEAN)
      expect(config.get(KEY_BOOLEAN)).to eq(false) # default setting
    end
  end

  describe '#add' do
    it 'adds a value to a list' do
      config.set(KEY_LOCALES, 'de')
      config.add(KEY_LOCALES, 'fr')
      expect(config.get(KEY_LOCALES)).to eq(%w[de fr])
    end

    it 'fails on non-list types' do
      expect do
        config.add(KEY_BOOLEAN, true)
      end.to raise_error(t('config.non_array_key', key: KEY_BOOLEAN))
    end
  end

  describe '#subtract' do
    it 'removes a value from a list' do
      config.set(KEY_LOCALES, %w[de fr])
      config.subtract(KEY_LOCALES, 'fr')
      expect(config.get(KEY_LOCALES)).to eq(['de'])
    end

    it 'fails on non list types' do
      expect do
        config.subtract(KEY_BOOLEAN, true)
      end.to raise_error(t('config.non_array_key', key: KEY_BOOLEAN))
    end
  end

  describe '#get' do
    it 'returns a configuration key' do
      config.set(KEY_LOCALES, 'de')
      expect(config.get(KEY_LOCALES)).to eq(['de'])
    end

    it 'returns paths relative to the user config file' do
      user_db = 'path1/file.txt'
      config.set(KEY_DB_CONFIG, user_db, :user)
      expected_path = File.absolute_path(File.join(File.join(File.dirname(config.user_settings_path), '..'), user_db))
      expect(config.get(KEY_DB_CONFIG, :user)).to eq(expected_path)
    end

    it 'returns paths relative to the project config file' do
      proj_db = 'path2/file.txt'
      config.set(KEY_DB_CONFIG, proj_db, :project)
      expected_path = File.absolute_path(File.join(File.join(File.dirname(config.project_settings_path), '..', proj_db)))
      expect(config.get(KEY_DB_CONFIG, :project)).to eq(expected_path)
    end
  end

  describe '#all' do
    it 'returns all configuration settings' do
      config.set(KEY_LOCALES, 'de')
      settings = config.all
      expect(settings).to be_a(Hash)
      expect(settings).to be_present
      expect(settings[KEY_LOCALES.to_sym]).to eq(%w[de])
    end
  end

  describe '#include?' do
    it 'tests if a configuration is set' do
      config.set(KEY_LOCALES, 'de')
      expect(config.include?(KEY_LOCALES)).to be_truthy
    end
  end

  describe '#save' do
    it 'saves settings to the config file' do
      config.set(KEY_LOCALES, 'de')
      config.save
    end
  end

  describe '#load' do
    it 'loads settings from the config file' do
      config.load
    end
  end
end
