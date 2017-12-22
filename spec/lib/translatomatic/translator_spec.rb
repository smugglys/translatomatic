RSpec.describe Translatomatic::Translator do
  describe :default do
    it "should find a working translator" do
      t = Translatomatic::Translator.default
      expect(t).to be
    end
  end
end
