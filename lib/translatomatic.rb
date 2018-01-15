require 'i18n'
require 'rails-i18n'
require 'i18n_data'

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

    private

    def init_i18n(lib_path)
      locale_path = File.join(File.dirname(lib_path), '..', 'config', 'locales')
      I18n.load_path += Dir[File.join(locale_path, '**', '*.yml')]
    end
  end

  begin
    init_i18n(__FILE__)
  end
end

require 'translatomatic/version'
require 'translatomatic/option'
require 'translatomatic/define_options'
require 'translatomatic/locale'
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
