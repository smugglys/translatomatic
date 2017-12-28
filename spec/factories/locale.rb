FactoryBot.define do
  factory :locale, class: Translatomatic::Locale do
    tag "en"
    initialize_with { new(tag) }
  end
end
