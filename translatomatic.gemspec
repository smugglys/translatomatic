
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

  # development
  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-mocks', '~> 3'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'

  # translation
  spec.add_dependency 'google_web_translate', '~> 0.2.2'

  # resource file parsing
  spec.add_dependency 'kramdown'           # markdown -> html
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'PoParser'
  spec.add_dependency 'reverse_markdown'   # html -> markdown
  spec.add_dependency 'treetop'
  spec.add_dependency 'rchardet'
  spec.add_dependency 'titlekit'

  # misc
  spec.add_dependency 'activerecord', '~> 5'
  spec.add_dependency 'i18n'
  spec.add_dependency 'i18n_data'          # iso country/language codes
  spec.add_dependency 'rails-i18n', '~> 5' # date/time/currency formats
  spec.add_dependency 'ruby-progressbar'
  spec.add_dependency 'thor', '= 0.20.0'   # using monkey patch
  spec.add_dependency 'builder'
  spec.add_dependency 'http-cookie', '~> 1'
  spec.add_dependency 'rainbow', '~> 3'
end
