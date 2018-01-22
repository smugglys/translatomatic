RSpec.describe Translatomatic::ResourceFile::Properties do
  include_examples 'a resource file',
                   test_files: ['test.properties', 'test2.properties']

  it 'converts \\n to newline and back' do
    path = fixture_path('test_multiline.properties')
    source = Translatomatic::ResourceFile.load(path)
    expect(source).to be # valid properties file

    # save properties
    target_path = create_tempfile('output.properties')
    source.save(target_path, no_created_by: true)

    expected_contents = fixture_read('test_multiline_save.properties')
    expect(target_path.read).to eq(expected_contents)
  end
end
