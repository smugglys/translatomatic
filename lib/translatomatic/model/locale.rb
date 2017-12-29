module Translatomatic
  module Model
    # Locale database record.
    # Used to store translations in the database.
    class Locale < ActiveRecord::Base
      has_many :texts, class_name: "Translatomatic::Model::Text"
      validates_presence_of :language
      validates_uniqueness_of :language, scope: [:script, :region]

      # Create a locale record from an I18n::Locale::Tag object or string
      # @return [Translatomatic::Model::Locale] Locale record
      def self.from_tag(tag)
        tag = Translatomatic::Locale.parse(tag)
        find_or_create_by!({
          language: tag.language, script: tag.script, region: tag.region
        })
      end

      # @return [String] Locale as string
      def to_s
        [language, script, region].compact.join("-")
      end
    end
  end
end
