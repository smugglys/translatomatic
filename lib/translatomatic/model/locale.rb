module Translatomatic
  module Model
    class Locale < ActiveRecord::Base
      has_many :texts, class_name: "Translatomatic::Model::Text"
      validates_uniqueness_of :language, scope: [:country, :variant]
    end
  end
end
