
module Translatomatic::Util

  def log
    Translatomatic::Config.instance.logger
  end

  def locale(tag)
    Translatomatic::Locale.parse(tag)
  end

  def string(value, locale)
    Translatomatic::String.new(value, locale)
  end
end
