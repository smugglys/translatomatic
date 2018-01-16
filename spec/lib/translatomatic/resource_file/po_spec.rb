RSpec.describe Translatomatic::ResourceFile::PO do
  include_examples 'a resource file'

  # test that properties with the same msgid but different msgctxt
  # are handled separately.
  it 'handles resource files with msgctxt' do
    file = load_test_file('test2.po')
    expect(file).to be
    expect(file.get("right.direction")).to eq("rechts")
    expect(file.get("right.correct")).to eq("recht")
  end
end
