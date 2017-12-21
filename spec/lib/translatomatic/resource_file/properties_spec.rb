RSpec.describe Translatomatic::ResourceFile::Properties do
  it "Converts \\n to newline and back" do
    path = fixture_path("test.properties")
    source = Translatomatic::ResourceFile.load(path)
    expect(source).to be  # valid properties file

    # copy properties to a new file and save
    target_path = create_tempfile('output.properties')
    target = Translatomatic::ResourceFile.load(target_path)
    source.properties.each do |key, value|
      target.set(key, value)
    end
    target.save

    # TODO: currently comments are stripped
    # ideally they would be translated or kept
    expected_contents = fixture_read("expected_result.properties")
    expect(target.path.read).to eq(expected_contents)
  end
end
