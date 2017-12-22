
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "translatomatic/version"

Gem::Specification.new do |spec|
  spec.name          = "translatomatic"
  spec.version       = Translatomatic::VERSION
  spec.authors       = ["Andrew Williams"]
  spec.email         = ["contact@smugglys.com"]

  spec.summary       = %q{Strings translation utility}
  spec.homepage      = "http://github.com/smugglys/translatomatic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = %w{translatomatic}
  spec.require_paths = ["lib"]

  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "yandex-translator"
  spec.add_dependency "easy_translate"
  spec.add_dependency "bing_translator", "~> 5.1.0"
  spec.add_dependency "sqlite3", "~> 1.3"
  spec.add_dependency "activerecord", "~> 5.0"
  spec.add_dependency "i18n"
  spec.add_dependency "i18n_data"
  spec.add_dependency "bigdecimal"
  spec.add_dependency "nokogiri"

  # TODO: i want to use mysql in my .translatomatic/database.yml but
  # other people shouldn't have to install it, how to make it optional?
  spec.add_dependency "mysql2"
end
