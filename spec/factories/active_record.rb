FactoryBot.define do

  factory :locale_model, class: Translatomatic::Model::Locale do
    language "en"
    script null
    region null
  end

  factory :text_model, class: Translatomatic::Model::Text do
    association :locale, factory: :locale_model
    sequence(:value) { |i| "text value #{i}" }
    #shared false
  end

end
