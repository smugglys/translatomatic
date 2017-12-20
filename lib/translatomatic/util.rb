require 'i18n_data'

module Translatomatic::Util

  # list of 2 letter country codes
  VALID_LANGUAGES = I18nData.languages.keys.collect { |i| i.downcase }.sort

  def parse_locale(tag, only_iso_639_1 = false)
    locale = tag.kind_of?(I18n::Locale::Tag) ? tag : I18n::Locale::Tag.tag(tag)
    locale = nil if only_iso_639_1 && !valid_iso639_1_language?(locale.language)
    locale
  end

  def valid_locale?(tag)
    # test if lang is a valid ISO 639-1 language
    locale = parse_locale(tag)
    locale && VALID_LANGUAGES.include?(locale.language) ? true : false
  end

  def log
    Translatomatic::Config.instance.logger
  end

end
