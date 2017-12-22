require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

require "bundler/setup"
require "translatomatic"
require 'webmock/rspec'
include WebMock

SPEC_DIR = File.dirname(__FILE__)
Dir[File.join(SPEC_DIR, "support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  include Helpers

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    create_test_database
  end
end
