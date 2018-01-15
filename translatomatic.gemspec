
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'translatomatic/version'

Gem::Specification.new do |spec|
  spec.name          = 'translatomatic'
  spec.version       = Translatomatic::VERSION
  spec.authors       = ['Andrew Williams']
  spec.email         = ['contact@smugglys.com']

  spec.summary       = 'File translation and conversion utility'
  spec.homepage      = Translatomatic::URL
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = %w[translatomatic]
  spec.require_paths = ['lib']

  spec.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs.

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-mocks', '~> 3'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'activerecord', '~> 5'
  spec.add_dependency 'easy_translate'
  spec.add_dependency 'i18n'
  spec.add_dependency 'i18n_data'
  spec.add_dependency 'kramdown'           # markdown -> html
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'PoParser'
  spec.add_dependency 'reverse_markdown'   # html -> markdown
  spec.add_dependency 'ruby-progressbar'
  spec.add_dependency 'thor', '~> 0.20'
  spec.add_dependency 'titlekit'
  spec.add_dependency 'builder'
end
