require 'i18n_data'

module Translatomatic::Util
  
  def log
    Translatomatic::Config.instance.logger
  end

end
