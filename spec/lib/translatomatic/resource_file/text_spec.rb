RSpec.describe Translatomatic::ResourceFile::Text do
  include_examples "a resource file", {
    load_properties: {
      "text" => "value 1\n",
    },
    save_properties: {
      "text" => "saved value 1",
    },
    locale_path_conversions: [
      PathConversion.new("path/to/file.$EXT", "path/to/file_$LOC.$EXT"),
      PathConversion.new("path/to/file_$LOC.$EXT", "path/to/file_$LOC.$EXT"),
    ]
  }
end
