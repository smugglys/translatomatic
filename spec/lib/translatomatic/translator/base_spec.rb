RSpec.describe Translatomatic::Translator::Base do

  class DummyTranslator < Translatomatic::Translator::Base
  end

  context :languages do
    it "returns an empty language list by default" do
      t = DummyTranslator.new
      expect(t.languages).to be_empty
    end
  end

  context :name do
    it "returns the translator name" do
      t = DummyTranslator.new
      expect(t.name).to eq(DummyTranslator.to_s)
    end
  end

end
