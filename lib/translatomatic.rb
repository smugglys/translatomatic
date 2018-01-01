require 'i18n'
require 'rails-i18n'

# Module containing all of the translation goodness
module Translatomatic
  # @return [Translatomatic::Config] configuration
  def self.config
    @config ||= Translatomatic::Config.new
  end

  private

  def self.init_i18n(lib_path)
    locale_path = File.join(File.dirname(lib_path), "..", "config", "locales")
    I18n.load_path += Dir[File.join(locale_path, "**", "*.yml")]
  end
end

begin
  Translatomatic.init_i18n(__FILE__)
end

require 'pathname'
require 'active_support/core_ext/hash'
require 'easy_translate'
require 'i18n_data'
require 'ruby-progressbar'

require 'translatomatic/option'
require 'translatomatic/locale'
require 'translatomatic/string'
require 'translatomatic/translation'
require 'translatomatic/util'
require 'translatomatic/version'
require 'translatomatic/logger'
require 'translatomatic/config'
require 'translatomatic/database'
require 'translatomatic/escaped_unicode'
require 'translatomatic/model'
require 'translatomatic/resource_file'
require 'translatomatic/http_request'
require 'translatomatic/translator'
require 'translatomatic/translation_result'
require 'translatomatic/converter_stats'
require 'translatomatic/converter'
require 'translatomatic/extractor'
require 'translatomatic/progress_updater'
require 'translatomatic/tmx'
require 'translatomatic/cli'
