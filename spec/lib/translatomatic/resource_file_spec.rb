require 'tempfile'

RSpec.describe Translatomatic::ResourceFile do

  context :load do
    it "loads a yaml file" do
      #yaml = fixture_read("config/locales/en.yml")
      path = fixture_path("config/locales/en.yml")
      file = Translatomatic::ResourceFile.load(path)
      expect(file).to be
      expect(file.format).to eq(:yaml)
      expect(file.get("en.hello_world")).to eq("Hello world!")
    end

    it "loads a property file" do
      path = fixture_path("test.properties")
      file = Translatomatic::ResourceFile.load(path)
      expect(file).to be
      expect(file.format).to eq(:properties)
      expect(file.get("key")).to eq("value")
    end

  end

  context :save do
    it "saves a yaml file" do
      contents = "en:\n  hello_world: Hello world!\n"
      expected_contents = "en:\n  hello_world: Goodbye\n"
      path = create_tempfile('en.yml', contents)
      file = Translatomatic::ResourceFile.load(path)
      expect(file.format).to eq(:yaml)
      file.set("en.hello_world", "Goodbye")
      file.save
      expect(File.read(path)).to eq(expected_contents)
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

  # test creating filenames from locales
  context :locale_path do
    # yaml
    it "converts config/locales/en.yml to fr.yml" do
      file = Translatomatic::ResourceFile.load("config/locales/en.yml")
      expect(file.locale_path("fr").to_s).to eq("config/locales/fr.yml")
    end

    # properties
    it "converts strings_en-US.properties to strings_fr.properties" do
      file = Translatomatic::ResourceFile.load("strings_en-US.properties")
      expect(file.locale_path("fr").to_s).to eq("strings_fr.properties")
    end

    # xcode strings
    it "converts en.lproj to zh-Hant.lproj" do
      path = "Project/en.lproj/Project.plist"
      file = Translatomatic::ResourceFile.load(path)
      expect(file.locale_path("zh-Hant").to_s).to eq("Project/zh-Hant.lproj/Project.plist")
    end

    # html
    it "converts index.html.de to index.html.fr" do
      file = Translatomatic::ResourceFile.load("index.html.de")
      expect(file.locale_path("fr").to_s).to eq("index.html.fr")
    end
  end

  context "Locale detection" do
    # yaml
    it "detects locale from fr.yml" do
      file = Translatomatic::ResourceFile.load("fr.yml")
      expect(file.locale.language).to eq("fr")
    end

    # properties
    it "detects locale from strings_de-DE.properties" do
      file = Translatomatic::ResourceFile.load("strings_de-DE.properties")
      expect(file.locale.language).to eq("de")
    end

    # xcode strings
    it "detects locale from Project/zh-Hant.lproj/Project.plist" do
      path = "Project/zh-Hant.lproj/Project.plist"
      file = Translatomatic::ResourceFile.load(path)
      expect(file.locale.to_s).to eq("zh-Hant")
    end

    # html
    it "detects locale from index.html.de" do
      file = Translatomatic::ResourceFile.load("index.html.de")
      expect(file.locale.language).to eq("de")
    end

  end

end
