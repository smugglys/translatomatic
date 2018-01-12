RSpec.describe Translatomatic::ResourceFile::Properties do
  include_examples 'a resource file',
                   test_files: %w[test.properties test2.properties]

  it 'converts \\n to newline and back' do
    path = fixture_path('test_multiline.properties')
    source = Translatomatic::ResourceFile.load(path)
    expect(source).to be # valid properties file

    # copy properties to a new file and save
    target_path = create_tempfile('output.properties')
    target = Translatomatic::ResourceFile.load(target_path)
    target.properties = source.properties
    target.save(target_path, no_created_by: true)

    # TODO: currently comments are stripped
    # ideally they would be translated or kept
    expected_contents = fixture_read('test_multiline_save.properties')
    expect(target.path.read).to eq(expected_contents)
  end

  # TODO: add support for propertyName: value
end
