require 'pathname'
require 'active_support/core_ext/hash'
require 'active_support/dependencies/autoload'

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
