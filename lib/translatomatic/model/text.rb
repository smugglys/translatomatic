module Translatomatic
  module Model
    class Text < ActiveRecord::Base
      belongs_to :locale, class_name: "Translatomatic::Model::Locale"
      belongs_to :from_text, class_name: "Translatomatic::Model::Text"
      has_many :translations, class_name: "Translatomatic::Model::Text",
        foreign_key: :from_text_id, dependent: :delete_all

      validates_presence_of :value
      validates_presence_of :locale
    end
  end
end
