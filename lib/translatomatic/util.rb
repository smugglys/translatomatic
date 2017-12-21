require 'i18n_data'

module Translatomatic::Util

  def parse_locale(tag, validate = true)
    locale = tag.kind_of?(I18n::Locale::Tag) ? tag : I18n::Locale::Tag.tag(tag)
    locale = nil if validate && !valid_locale?(locale)
    locale
  end

  def valid_locale?(tag)
    # test if lang is a valid ISO 639-1 language
    locale = parse_locale(tag, false)
    locale && VALID_LANGUAGES.include?(locale.language) ? true : false
  end

  def log
    Translatomatic::Config.instance.logger
  end

  private

  # list of 2 letter country codes
  VALID_LANGUAGES = I18nData.languages.keys.collect { |i| i.downcase }.sort
end
