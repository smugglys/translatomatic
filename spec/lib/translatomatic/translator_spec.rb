RSpec.describe Translatomatic::Translator do
  describe :available do
    it "should find all available translators" do
      list = Translatomatic::Translator.available
      expect(list).to be
    end
  end
end
