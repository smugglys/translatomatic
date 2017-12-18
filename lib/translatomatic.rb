module Translatomatic
  def self.config
    @config ||= Translatomatic::Config.new
  end
end

require 'translatomatic/version'
require 'translatomatic/config'
require 'translatomatic/cli'
require 'translatomatic/escaped_unicode'
require 'translatomatic/resource_bundle'
require 'translatomatic/resource_file'
require 'translatomatic/translator'
require 'translatomatic/database'
require 'translatomatic/model'

begin
  I18n::Locale::Tag.implementation = I18n::Locale::Tag::Rfc4646
end
