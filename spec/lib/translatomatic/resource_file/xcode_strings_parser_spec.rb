RSpec.describe Translatomatic::ResourceFile::XCodeStrings::Parser do
  before(:all) do
    @parser = described_class.new
  end

  it 'parses a comment' do
    text = '/* this is a comment */'
    node = @parser.parse(text)
    expect(node).to be
    expect(node.content).to eq([[:comment, ' this is a comment ']])
  end

  it 'parses a definition' do
    text = '"key" = "value";'
    node = @parser.parse(text)
    expect(node).to be
    expect(node.content).to eq([[:definition, 'key', 'value']])
  end

  it 'parses a definition with escaped double quotes' do
    text = '"key" = "value \\"quoted\\"";'
    node = @parser.parse(text)
    expect(node).to be
    expect(node.content).to eq([[:definition, 'key', 'value \\"quoted\\"']])
  end

  it 'parses two definitions' do
    text = %("key" = "value";\n\n"key2" = "value2";)
    node = @parser.parse(text)
    expect(node).to be
    expect(node.content).to eq(
      [[:definition, 'key', 'value'], [:definition, 'key2', 'value2']]
    )
  end

  it 'parses a document' do
    text = %(/* comment */\n"key" = "value";\n)
    node = @parser.parse(text)
    expect(node).to be
    expect(node.content).to eq(
      [[:comment, ' comment '], [:definition, 'key', 'value']]
    )
  end
end
