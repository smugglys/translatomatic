RSpec.describe Translatomatic::ResourceFile::Properties::Parser do
  let(:parser) { create_parser }

  it 'parses a comment' do
    text = '# this is a comment'
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq([[:comment, ' this is a comment', '#']])
  end

  it 'parses a definition' do
    text = 'key = value'
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq([[:definition, 'key', 'value']])
  end

  it 'does not use a comment as a key' do
    text = "\n# this is a comment: woo"
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq([[:comment, ' this is a comment: woo', '#']])
  end

  it 'parses a definition with a colon' do
    text = 'key: value'
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq([[:definition, 'key', 'value']])
  end

  it 'parses a definition with an escaped space in the key' do
    text = 'key\\ with\\ spaces = value'
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq([[:definition, 'key\\ with\\ spaces', 'value']])
  end

  it 'parses a definition with a multiline value' do
    text = "key = multiline\\\nvalue"
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq([[:definition, 'key', "multiline\\\nvalue"]])
  end

  it 'parses two definitions' do
    text = %Q(key = value\nkey2 = value2)
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq(
      [[:definition, 'key', 'value'], [:definition, 'key2', 'value2']]
    )
  end

  it 'parses a document' do
    text = %Q(# comment\nkey = value\n)
    node = attempt_parse(text)
    expect(node).to be
    expect(node.content).to eq(
      [[:comment, ' comment', '#'], [:definition, 'key', 'value']]
    )
  end

  def attempt_parse(text)
    result = parser.parse(text, consume_all_input: false)
    puts parser.failure_reason unless result
    result
  end

  def create_parser
    described_class.new
  end
end
