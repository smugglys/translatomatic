RSpec.describe Translatomatic::ResourceFile::Plist do
  include_examples "a resource file", {
    locale_path_conversions: [
      PathConversion.new("$LOC.lproj/file.$EXT", "$LOC.lproj/file.$EXT"),
      PathConversion.new("path/to/file.$EXT", "path/to/file_$LOC.$EXT"),
      PathConversion.new("path/to/file_$LOC.$EXT", "path/to/file_$LOC.$EXT"),
    ]
  }

  # plist2 has all the available data types of a plist
  it "loads test2.plist" do
    expected_properties = {
      "arraykey.key0" => "array value 1",
      "arraykey.key1" => "array value 2",
      "datakey" => "ZGF0YSB2YWx1ZQ==",
      "datekey" => "2011-04-01T02:09:15Z",
      "intkey" => 10,
      "realkey" => 3.14,
      "boolkey1" => true,
      "boolkey2" => false,
      "dictkey.nestedkey" => "nested value"
    }

    file = load_test_file("test2.plist")
    expect(file).to be
    expect(file.properties).to eq(expected_properties)
  end

  # plist3 has an array at top level
  it "loads test3.plist" do
    expected_properties = {
      "key0.property1" => "value 1",
    }

    file = load_test_file("test3.plist")
    expect(file).to be
    expect(file.properties).to eq(expected_properties)
  end
end
