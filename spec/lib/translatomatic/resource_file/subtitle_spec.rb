RSpec.describe Translatomatic::ResourceFile::Subtitle do
  include_examples 'a resource file',
                   autogenerated_keys: true, skip_context_test: true
end
