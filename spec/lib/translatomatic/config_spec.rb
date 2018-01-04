RSpec.describe Translatomatic::Config do

  KEY_LOCALES = "target_locales"
  KEY_DEBUG = "debug"

  let(:config) { Translatomatic::Config.instance }

  describe :set do
    it "sets a configuration key" do
      config.set(KEY_LOCALES, "de")
      expect(config.get(KEY_LOCALES)).to eq(["de"])
    end

    it "sets a boolean setting" do
      config.set(KEY_DEBUG, "true")
      expect(config.get(KEY_DEBUG)).to eq(true)
    end

    it "writes configuration to file" do
      config.set(KEY_LOCALES, "de")
      expect(config.get(KEY_LOCALES)).to eq(["de"])
      config.load
      expect(config.get(KEY_LOCALES)).to eq(["de"])
    end

    it "does not set an invalid configuration option" do
      key = "invalid key"
      expect {
        config.set(key, "value ")
      }.to raise_error(t("config.invalid_key", key: key))
    end
  end

  describe :remove do
    it "writes configuration to file" do
      config.set(KEY_LOCALES, "de")
      expect(config.get(KEY_LOCALES)).to eq(["de"])
      config.remove(KEY_LOCALES)
      config.load
      expect(config.get(KEY_LOCALES)).to be_empty
    end

    it "removes a boolean setting" do
      config.set(KEY_DEBUG, "false")
      expect(config.get(KEY_DEBUG)).to eq(false)
      config.remove(KEY_DEBUG)
      expect(config.get(KEY_DEBUG)).to eq(false)  # default setting
    end
  end

  describe :get do
    it "gets a configuration key" do
      config.set(KEY_LOCALES, "de")
      expect(config.get(KEY_LOCALES)).to eq(["de"])
    end
  end

  describe :include? do
    it "tests if a configuration is set" do
      config.set(KEY_LOCALES, "de")
      expect(config.include?(KEY_LOCALES)).to be_truthy
    end
  end

  describe :save do
    it "saves settings to the config file" do
      config.set(KEY_LOCALES, "de")
      config.save
    end
  end

  describe :load do
    it "loads settings from the config file" do
      config.load
    end
  end

end
