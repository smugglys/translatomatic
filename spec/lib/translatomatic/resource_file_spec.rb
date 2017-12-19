require 'tempfile'

RSpec.describe Translatomatic::ResourceFile do

  context :yaml do
    it "loads a yaml file" do
      #yaml = fixture_read("config/locales/en.yml")
      path = fixture_path("config/locales/en.yml")
      file = Translatomatic::ResourceFile.load(path)
      expect(file).to be
      expect(file.format).to eq(:yaml)
      expect(file.get("en.hello_world")).to eq("Hello world!")
    end

    it "saves a yaml file" do
      contents =<<EOM
en:
  hello_world: Hello world!
EOM
      expected_contents =<<EOM
en:
  hello_world: Goodbye
EOM
      path = create_tempfile('en.yml', contents)
      file = Translatomatic::ResourceFile.load(path)
      expect(file.format).to eq(:yaml)
      file.set("en.hello_world", "Goodbye")
      file.save
      expect(File.read(path)).to eq(expected_contents)
    end
  end

  context :properties do
    it "loads a property file" do
      path = fixture_path("test.properties")
      file = Translatomatic::ResourceFile.load(path)
      expect(file).to be
      expect(file.format).to eq(:properties)
      expect(file.get("key")).to eq("value")
    end

    it "saves a property file" do
      contents = "key = value\n"
      path = create_tempfile('test.properties', contents)
      file = Translatomatic::ResourceFile.load(path)
      expect(file.format).to eq(:properties)
      file.set("key", "new value")
      file.save
      expect(File.read(path)).to eq("key = new value\n")
    end
  end

  context "Locale detection" do
    it "detects locale from en.yml" do
      file = Translatomatic::ResourceFile.load("en.yml")
      expect(file.locale.language).to eq("en")
    end

    it "detects locale from strings_en-US.properties" do
      file = Translatomatic::ResourceFile.load("strings_en-US.properties")
      expect(file.locale.language).to eq("en")
    end

    it "detects locale from Project/zh-Hant.lproj/Project.plist" do
      path = "Project/zh-Hant.lproj/Project.plist"
      file = Translatomatic::ResourceFile.load(path)
      expect(file.locale.to_s).to eq("zh-Hant")
    end
  end

  private

end
