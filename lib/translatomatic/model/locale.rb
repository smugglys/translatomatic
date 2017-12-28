module Translatomatic
  module Model
    class Locale < ActiveRecord::Base
      has_many :texts, class_name: "Translatomatic::Model::Text"
      validates_presence_of :language
      validates_uniqueness_of :language, scope: [:script, :region]

      class << self
        include Translatomatic::Util
      end

      # create a locale record from an I18n::Locale::Tag object or string
      def self.from_tag(tag)
        tag = parse_locale(tag) if tag.kind_of?(String)
        find_or_create_by!({
          language: tag.language, script: tag.script, region: tag.region
        })
      end

    end
  end
end
