module Translatomatic
  module Model
    class Text < ActiveRecord::Base
      belongs_to :locale, class_name: "Translatomatic::Model::Locale"
      belongs_to :translated_from, class_name: "Translatomatic::Model::Text"
      has_many :translated_to, class_name: "Translatomatic::Model::Text",
        foreign_key: :translated_from_id

      validates_presence_of :value
      validates_presence_of :locale
    end
  end
end
