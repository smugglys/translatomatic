RSpec.describe Translatomatic::ResourceFile::RESW do
  include_examples "a resource file", {
    locale_path_conversions: [
      PathConversion.new("strings/$LOC/file.$EXT", "strings/$LOC/file.$EXT"),
    ]
  }
end
