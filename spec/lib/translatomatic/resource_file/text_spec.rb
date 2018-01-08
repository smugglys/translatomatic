RSpec.describe Translatomatic::ResourceFile::Text do
  include_examples "a resource file", {
    load_properties: {
      "text" => "value 1\n",
    },
    save_properties: {
      "text" => "saved value 1",
    }
  }
end
