module Translatomatic
  module Model
    # Text database record.
    # Used to store translations in the database.
    class Text < ActiveRecord::Base
      belongs_to :locale, class_name: "Translatomatic::Model::Locale"
      belongs_to :from_text, class_name: "Translatomatic::Model::Text"
      has_many :translations, class_name: "Translatomatic::Model::Text",
        foreign_key: :from_text_id, dependent: :delete_all

      validates_presence_of :value
      validates_presence_of :locale

      def is_translated?
        !from_text_id.nil?
      end
    end
  end
end
