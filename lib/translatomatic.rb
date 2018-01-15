
# gem :rchardet19, provided_by: :rchardet
# titlekit has rchardet19 dependency, but we don't want that
dependency = Gem::Dependency.new('rchardet19')
specs = dependency.matching_specs
if specs
  path = File.join(specs[0].full_gem_path, 'lib')
  $LOAD_PATH.delete(path)
end

require 'pathname'
require 'active_support/core_ext/hash'
require 'rchardet'

# Module containing all of the translation goodness
module Translatomatic
  class << self
    # @return [Translatomatic::Config] configuration
    def config
      @config ||= Translatomatic::Config.new
    end
  end
end

require 'translatomatic/version'
require 'translatomatic/locale'
require 'translatomatic/slurp'
require 'translatomatic/i18n'
require 'translatomatic/option'
require 'translatomatic/define_options'
require 'translatomatic/string_escaping'
require 'translatomatic/string'
require 'translatomatic/translation'
require 'translatomatic/util'
require 'translatomatic/version'
require 'translatomatic/logger'
require 'translatomatic/type_cast'
require 'translatomatic/config'
require 'translatomatic/database'
require 'translatomatic/escaped_unicode'
require 'translatomatic/model'
require 'translatomatic/resource_file'
require 'translatomatic/http_request'
require 'translatomatic/converter'
require 'translatomatic/translator'
require 'translatomatic/translation_result'
require 'translatomatic/translation_stats'
require 'translatomatic/file_translator'
require 'translatomatic/extractor'
require 'translatomatic/progress_updater'
require 'translatomatic/tmx'
require 'translatomatic/cli'
