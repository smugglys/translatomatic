module Translatomatic::Util

  def parse_locale(tag)
    tag.kind_of?(I18n::Locale::Tag) ? tag : I18n::Locale::Tag.tag(tag)
  end

  def log
    Translatomatic::Config.instance.logger
  end
end
