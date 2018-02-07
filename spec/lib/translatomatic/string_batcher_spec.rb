RSpec.describe Translatomatic::StringBatcher do
  it 'limits number of strings by count' do
    strings = %W{a b c d e f g}
    batcher = create_batcher(strings, max_length: 100, max_count: 3)
    results = []
    batcher.each_batch { |list| results << list }

    expect(results.length).to eq(3)
    expect(results[0]).to eq(%W{a b c})
    expect(results[1]).to eq(%W{d e f})
    expect(results[2]).to eq(%W{g})
  end

  it 'limits number of strings by length' do
    strings = %W{string1 string2 string3 string4 string5}
    batcher = create_batcher(strings, max_length: 20, max_count: 100)
    results = []
    batcher.each_batch { |list| results << list }

    expect(results.length).to eq(3)
    expect(results[0]).to eq(%W{string1 string2})
    expect(results[1]).to eq(%W{string3 string4})
    expect(results[2]).to eq(%W{string5})
  end

  it 'fails if a string exceeds the maximum length' do
    string = 'thisisaverylongstring'
    max_length = string.length - 1
    batcher = create_batcher([string], max_length: max_length, max_count: 1000)
    expect {
      batcher.each_batch {}      
    }.to raise_error(t('translator.string_too_long'))
  end

  it 'returns all strings if limits are not exceeded' do
    strings = %W{a b c d e f g}
    batcher = create_batcher(strings, max_length: 100, max_count: 100)
    results = []
    batcher.each_batch { |list| results << list }

    expect(results.length).to eq(1)
    expect(results[0]).to eq(strings)
  end

  it 'returns all strings if max count is nil' do
    strings = %W{a b c d e f g}
    batcher = create_batcher(strings, max_length: 100, max_count: nil)
    results = []
    batcher.each_batch { |list| results << list }

    expect(results.length).to eq(1)
    expect(results[0]).to eq(strings)
  end

  def create_batcher(strings, max_length:, max_count:)
    described_class.new(strings, max_length: max_length, max_count: max_count)
  end
end