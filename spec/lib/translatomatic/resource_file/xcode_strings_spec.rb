RSpec.describe Translatomatic::ResourceFile::XCodeStrings do
  include_examples "a resource file", {
    locale_path_conversions: [
      PathConversion.new("$LOC.lproj/file.$EXT", "$LOC.lproj/file.$EXT"),
      PathConversion.new("path/to/file.$EXT", "path/to/file_$LOC.$EXT"),
      PathConversion.new("path/to/file_$LOC.$EXT", "path/to/file_$LOC.$EXT"),
    ]
  }
end
