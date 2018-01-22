RSpec.describe Translatomatic::Metadata do
  let(:metadata) { new_metadata }

  it "parses a tm.context comment" do
    key = "key1"
    metadata.parse_comment("ra ra ra tm.context: blah foo ")
    metadata.assign_key(key) # above comment associated with this key
    expect(metadata.get_context(key)).to eq(["blah foo"])
  end

  it "parses multiple tm.context comments" do
    key = "key1"
    metadata.parse_comment("# ra ra ra tm.context: blah foo\n# tm.context: second")
    metadata.assign_key(key) # above comment associated with this key
    expect(metadata.get_context(key)).to eq(["blah foo", "second"])
  end

  it "discards tm.context comments when there is no key" do
    key = "key1"
    metadata.assign_key(key) # this key has no associated comments
    metadata.parse_comment("ra ra ra tm.context:blah foo ")
    expect(metadata.get_context(key)).to eq(nil)
  end

  def new_metadata
    described_class.new
  end
end
