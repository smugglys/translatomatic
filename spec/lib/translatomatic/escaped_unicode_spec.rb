RSpec.describe Translatomatic::EscapedUnicode do

  context :escape do
    it "converts utf8 characters to unicode escape sequences" do
      string = "foo \u00a9 bar"
      converted = Translatomatic::EscapedUnicode.escape(string)
      expect(converted).to eq("foo \\u00a9 bar")
    end
  end

  context :unescape do
    it "converts unicode escape sequences to utf8" do
      string = "foo \\u00a9 bar"
      converted = Translatomatic::EscapedUnicode.unescape(string)
      expect(converted).to eq("foo \u00a9 bar")
    end
  end
end
