module Translatomatic
  def self.config
    @config ||= Translatomatic::Config.new
  end
end

require 'translatomatic/util'
require 'translatomatic/version'
require 'translatomatic/config'
require 'translatomatic/cli'
require 'translatomatic/database'
require 'translatomatic/escaped_unicode'
require 'translatomatic/model'
require 'translatomatic/resource_bundle'
require 'translatomatic/resource_file'
require 'translatomatic/translator'
require 'translatomatic/translation'

begin
  I18n::Locale::Tag.implementation = I18n::Locale::Tag::Rfc4646
end
