require 'simplecov'
SimpleCov.start

require "bundler/setup"
require "translatomatic"
require "helpers"

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
