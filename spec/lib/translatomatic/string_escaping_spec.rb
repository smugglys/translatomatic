RSpec.describe Translatomatic::StringEscaping do
  context '#escape' do
    it "converts nil to nil" do
      expect(escape(nil)).to eq(nil)
    end

    it "converts newlines to '\\n'" do
      expect(escape("\n")).to eq('\n')
    end
  end

  context '#unescape' do
    it "converts nil to nil" do
      expect(unescape(nil)).to eq(nil)
    end

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

  def escape(value, include = '')
    described_class.escape(value, include)
  end

  def unescape(value)
    described_class.unescape(value)
  end
end
