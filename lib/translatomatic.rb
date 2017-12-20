module Translatomatic
  def self.config
    @config ||= Translatomatic::Config.new
  end
end

require 'translatomatic/util'
require 'translatomatic/version'
require 'translatomatic/config'
require 'translatomatic/converter'
require 'translatomatic/database'
require 'translatomatic/escaped_unicode'
require 'translatomatic/model'
require 'translatomatic/resource_file'
require 'translatomatic/resource_bundle'
require 'translatomatic/translator'
require 'translatomatic/translation_result'
require 'translatomatic/cli'

begin
  I18n::Locale::Tag.implementation = I18n::Locale::Tag::Rfc4646
end
