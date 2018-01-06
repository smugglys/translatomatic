source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/smugglys/translatomatic" }

def gem_installed?(args)
  name, *version = *args
  dependency = Gem::Dependency.new(name, *version)
  specs = dependency.matching_specs
  specs && !specs.empty?
end

def optional_gem(*args)
  gem *args if gem_installed?(args)
end

# database adapters
optional_gem 'mysql2', platform: :ruby
optional_gem 'postgresql', platform: :ruby
optional_gem 'ruby-oci8', platform: :ruby
gem "sqlite3", '~> 1.3', platform: :ruby

# bigdecimal required by crack-0.4.3 on cygwin
optional_gem 'bigdecimal'

# jruby database adapters
optional_gem 'activerecord-jdbc-adapter', platform: :jruby
optional_gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby
optional_gem 'activerecord-jdbcmysql-adapter', platform: :jruby
optional_gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby

# Specify your gem's dependencies in translatomatic.gemspec
gemspec
