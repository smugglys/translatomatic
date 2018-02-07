RSpec.describe Translatomatic::Config do
  KEY_LOCALES = 'target_locales'.freeze
  KEY_DB_CONFIG = 'database_config'.freeze
  KEY_BOOLEAN = 'no_wank'.freeze

  def config
    Translatomatic.config
  end

  before(:each) do
    reset_test_config
  end

  after(:all) do
    reset_test_config
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
      # dump_all_config
      config.send(:load)
      expect(config.get(KEY_LOCALES)).to eq(['de'])
    end

    it 'does not set an invalid configuration option' do
      key = 'invalid key'
      expect {
        config.set(key, 'value ')
      }.to raise_error(t('config.invalid_key', key: key))
    end

    it 'chages project settings by default when within a project' do
      config.set(KEY_LOCALES, 'de')
      expect(config.get(KEY_LOCALES, location: :project)).to eq(['de'])
      expect(config.get(KEY_LOCALES, location: :user)).to eq([])
    end

    it 'changes user settings by default when outside of a project' do
      reset_test_config(project_path: nil)
      config.set(KEY_LOCALES, 'de')
      expect(config.get(KEY_LOCALES, location: :user)).to eq(['de'])
      expect(config.get(KEY_LOCALES, location: :project)).to eq([])
    end

    it 'changes a per-file setting with a for_file argument' do
      for_file = 'rah.txt'
      config.set(KEY_LOCALES, 'de', location: :project, for_file: for_file)
      expect(config.get(KEY_LOCALES, location: :user)).to eq([])
      expect(config.get(KEY_LOCALES, location: :project)).to eq([])
      expect(config.get(KEY_LOCALES, location: :project, for_file: for_file)).to eq(['de'])
    end

    it 'keeps existing per-file settings' do
      for_file = 'rah.txt'
      config.set(KEY_LOCALES, 'de', for_file: for_file)
      expect {
        config.set(KEY_BOOLEAN, 'true', for_file: for_file)
      }.to_not change {
        config.get(KEY_LOCALES, for_file: for_file)
      }
    end
  end

  describe '#unset' do
    it 'writes configuration to file' do
      config.set(KEY_LOCALES, 'de')
      expect(config.get(KEY_LOCALES)).to eq(['de'])
      config.unset(KEY_LOCALES)
      config.send(:load)
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
      expect {
        config.add(KEY_BOOLEAN, true)
      }.to raise_error(t('config.non_array_key', key: KEY_BOOLEAN))
    end
  end

  describe '#subtract' do
    it 'removes a value from a list' do
      config.set(KEY_LOCALES, %w[de fr])
      config.subtract(KEY_LOCALES, 'fr')
      expect(config.get(KEY_LOCALES)).to eq(['de'])
    end

    it 'fails on non list types' do
      expect {
        config.subtract(KEY_BOOLEAN, true)
      }.to raise_error(t('config.non_array_key', key: KEY_BOOLEAN))
    end
  end

  describe '#get' do
    it 'returns a configuration key' do
      expect(config.get(:no_wank)).to eq(false)
    end

    it 'returns paths relative to the user path' do
      user_db = 'path1/file.txt'
      config.set(KEY_DB_CONFIG, user_db, location: :user)
      # dump_all_config
      expected_path = absolute_path(config.user_path, user_db)
      expect(config.get(KEY_DB_CONFIG, location: :user)).to eq(expected_path)
    end

    it 'returns paths relative to the project path' do
      proj_db = 'path2/file.txt'
      config.set(KEY_DB_CONFIG, proj_db, location: :project)
      expected_path = absolute_path(config.project_path, proj_db)
      expect(config.get(KEY_DB_CONFIG, location: :project)).to eq(expected_path)
    end

    it 'returns values set at the user level with no location' do
      expect {
        config.set(KEY_BOOLEAN, 'true', location: :user)
        # dump_all_config
      }.to change { config.get(KEY_BOOLEAN) }.from(false).to(true)
    end

    describe 'for_file' do
      it 'gets a configuration key for a matched file' do
        for_file = 'path/file.txt'
        expect {
          config.set(KEY_BOOLEAN, 'true', for_file: for_file)
        }.to change {
          config.get(KEY_BOOLEAN, for_file: for_file)
        }.from(false).to(true)
      end

      it 'gets a configuration key for a matched parent file' do
        for_file_parent = 'path'
        for_file = 'path/file.txt'
        expect {
          config.set(KEY_BOOLEAN, 'true', for_file: for_file_parent)
        }.to change {
          config.get(KEY_BOOLEAN, for_file: for_file)
        }.from(false).to(true)
      end

      it 'skips file configuration that is not a match' do
        for_file = 'path/file.txt'
        expect {
          config.set(KEY_BOOLEAN, 'true', for_file: 'some/other/path')
        }.to_not change {
          config.get(KEY_BOOLEAN, for_file: for_file)
        }
      end

      it 'merges matching file configurations' do
        for_file = 'path1/path2/file.txt'
        config.set(KEY_BOOLEAN, 'true', for_file: 'path1')
        config.set(KEY_LOCALES, 'de', for_file: 'path1/path2')
        expect(config.get(KEY_BOOLEAN, for_file: for_file)).to be_truthy
        expect(config.get(KEY_LOCALES, for_file: for_file)).to eq(['de'])
      end

      it 'includes user configuration' do
        expect {
          config.set(KEY_BOOLEAN, 'true', location: :user)
        }.to change {
          # file specific configuration should inherit from user config
          config.get(KEY_BOOLEAN, for_file: 'path/file.txt')
        }.from(false).to(true)
      end
    end
  end

  describe '#include?' do
    it 'tests if a configuration is set' do
      config.set(KEY_LOCALES, 'de')
      expect(config.include?(KEY_LOCALES)).to be_truthy
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
end
