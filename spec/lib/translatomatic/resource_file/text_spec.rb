RSpec.describe Translatomatic::ResourceFile::Text do
  include_examples "a resource file", {
    load_properties: {
      "text" => "- value 1\n- value 2\n- value 3\n",
    },
    save_properties: {
      "text" => "- saved value 1\n- saved value 2\n- saved value 3",
    }
  }
end
