RSpec.describe Translatomatic::ResourceFile::YAML do
  include_examples "a resource file", {
    load_properties: {
      "key1" => "value 1",
      "ns.key2" => "value 2"
    },
    save_properties: {
      "key1" => "saved value 1",
      "ns.key2" => "saved value 2"
    },
    locale_path_conversions: [
      PathConversion.new("config/locales/$LOC.$EXT", "config/locales/$LOC.$EXT"),
      PathConversion.new("path/to/file.$EXT", "path/to/file_$LOC.$EXT"),
      PathConversion.new("path/to/file_$LOC.$EXT", "path/to/file_$LOC.$EXT"),
    ]
  }
end
