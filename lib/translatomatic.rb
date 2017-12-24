module Translatomatic
  def self.config
    @config ||= Translatomatic::Config.new
  end
end

require 'pathname'
require 'active_support/core_ext/hash'
require 'easy_translate'
require 'i18n_data'
require 'ruby-progressbar'

require 'translatomatic/option'
require 'translatomatic/locale'
require 'translatomatic/util'
require 'translatomatic/version'
require 'translatomatic/logger'
require 'translatomatic/config'
require 'translatomatic/database'
require 'translatomatic/escaped_unicode'
require 'translatomatic/model'
require 'translatomatic/resource_file'
require 'translatomatic/translator'
require 'translatomatic/translation_result'
require 'translatomatic/converter_stats'
require 'translatomatic/converter'
require 'translatomatic/extractor'
require 'translatomatic/progress_updater'
require 'translatomatic/cli'
