
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "translatomatic/version"

Gem::Specification.new do |spec|
  spec.name          = "translatomatic"
  spec.version       = Translatomatic::VERSION
  spec.authors       = ["Andrew Williams"]
  spec.email         = ["sobakasu@gmail.com"]

  spec.summary       = %q{Strings translation utility}
  spec.homepage      = "http://github.com/sobakasu/translatomatic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = %w{translatomatic}
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.0"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "yandex-translator"
  spec.add_dependency "easy_translate"
  spec.add_dependency "bing_translator"
  spec.add_dependency "sqlite3", "~> 1.3"
  spec.add_dependency "activerecord", "~> 5.0"
  spec.add_dependency "i18n"
  spec.add_dependency "i18n_data"
end
