module Translatomatic::Util

  def parse_locale(string)
    I18n::Locale::Tag.tag(string)
  end

  def log
    Translatomatic::Config.instance.logger
  end
end
