RSpec.describe Translatomatic::ResourceFile::XCodeStrings do
  include_examples 'a resource file'

  # plist2 has all the available data types of a plist
  it 'loads test2.strings' do
    expected_properties = {
      'property1' => "line1\nline2",  # newline should be unescaped
      'property2' => "line1\nline2",  # multi line string
      'property3' => 'line with "quoted text"', # string with quotes
    }

    file = load_test_file('test2.strings')
    expect(file).to be
    expect(file.properties).to eq(expected_properties)
  end
end
