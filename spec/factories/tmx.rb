FactoryBot.define do
  factory :tmx_unit, class: Translatomatic::TMX::TranslationUnit do
    skip_create
    initialize_with do
      new([build(:tmx_locale_string, value: "Yoghurt", tag: "en"),
           build(:tmx_locale_string, value: "Yoplait", tag: "fr")])
    end
  end

  factory :tmx_document, class: Translatomatic::TMX::Document do
    skip_create
    initialize_with { new([build(:tmx_unit)], build(:locale), "Test") }
  end

  factory :tmx_locale_string, class: Translatomatic::TMX::LocaleString do
    value "Yoghurt"
    tag "en"
    skip_create
    initialize_with { new(value, build(:locale, tag: tag)) }
  end

end
