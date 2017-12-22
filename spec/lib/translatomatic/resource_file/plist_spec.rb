RSpec.describe Translatomatic::ResourceFile::Plist do
  include_examples "a resource file", {
    locale_path_conversions: [
      PathConversion.new("Project/$LOC.lproj/file.$EXT", "Project/$LOC.lproj/file.$EXT"),
      PathConversion.new("path/to/file.$EXT", "path/to/file_$LOC.$EXT"),
      PathConversion.new("path/to/file_$LOC.$EXT", "path/to/file_$LOC.$EXT"),
    ]
  }
end
