RSpec.describe Translatomatic::ResourceFile::Markdown do
  # markdown is converted to html internally.
  # there are no keys in the html file, so they are just named 'key1', 'key2'
  include_examples 'a resource file',
                   autogenerated_keys: true
end
