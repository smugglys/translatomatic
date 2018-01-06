RSpec.describe Translatomatic::ResourceFile::CSV do
  include_examples "a resource file", {
    locale_path_conversions: [
      PathConversion.new("path/to/file.$EXT", "path/to/file_$LOC.$EXT"),
      PathConversion.new("path/to/file_$LOC.$EXT", "path/to/file_$LOC.$EXT"),
    ]
  }
end
