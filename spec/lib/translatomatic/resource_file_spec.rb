RSpec.describe Translatomatic::ResourceFile do
  it 'finds resource files' do
    fixture_dir = Pathname.new(fixture_path('test.properties')).parent
    files = described_class.find(fixture_dir)
    expect(files).to be
    expect(files).to_not be_empty
  end
end
