module Translatomatic
  module Model
    class Locale < ActiveRecord::Base
      has_many :texts, class_name: "Translatomatic::Model::Text"
      validates_presence_of :language
      validates_uniqueness_of :language, scope: [:script, :region]

      # create a locale record from an I18n::Locale::Tag object or string
      def self.from_tag(tag)
        tag = Translatomatic::Locale.parse(tag)
        find_or_create_by!({
          language: tag.language, script: tag.script, region: tag.region
        })
      end

      def to_s
        [language, script, region].compact.join("-")
      end
    end
  end
end
