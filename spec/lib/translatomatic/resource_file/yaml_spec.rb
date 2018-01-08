RSpec.describe Translatomatic::ResourceFile::YAML do
  include_examples "a resource file", {
    load_properties: {
      "property1" => "value 1",
      "ns.property2" => "value 2"
    },
    save_properties: {
      "property1" => "saved value 1",
      "ns.property2" => "saved value 2"
    }
  }
end
