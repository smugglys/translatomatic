RSpec.describe Translatomatic::ResourceFile::HTML do
  include_examples "a resource file", {
    locale_path_conversions: [
      PathConversion.new("path/to/file.$EXT", "path/to/file.$EXT.$LOC"),
      PathConversion.new("path/to/file.$EXT.$LOC", "path/to/file.$EXT.$LOC"),
      PathConversion.new("path/to/file.$LOC.$EXT", "path/to/file.$LOC.$EXT"),
    ]
  }
end
