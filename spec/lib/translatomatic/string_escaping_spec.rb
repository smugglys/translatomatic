RSpec.describe Translatomatic::StringEscaping do
  context '#escape' do
    it "converts newlines to '\\n'" do
      expect(escape("\n")).to eq('\n')
    end
  end

  context '#unescape' do
    it "converts '\\n' to newlines" do
      expect(unescape('\n')).to eq("\n")
    end

    it "converts \u00a9 to copyright" do
      expect(unescape('\u00a9')).to eq("\u00a9")
    end

    it "converts \x41 to 'A'" do
      expect(unescape('\x41')).to eq("A")
    end
  end

  def escape(value, skip = '')
    described_class.escape(value, skip)
  end

  def unescape(value)
    described_class.unescape(value)
  end
end
