require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

ENV['TEST'] = '1'
require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
include WebMock::API

require 'translatomatic'

SPEC_DIR = File.dirname(__FILE__)
Dir[File.join(SPEC_DIR, 'support/**/*.rb')].sort.each { |f| require f }
include Helpers
include DatabaseHelpers

RSpec.configure do |config|
  config.include Translatomatic::Util

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    create_test_database
    use_test_config
  end
end
