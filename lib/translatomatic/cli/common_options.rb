module Translatomatic::CLI
  # Defines options common to all command line methods
  class CommonOptions
    private

    include Translatomatic::DefineOptions
    include Translatomatic::Util

    define_option :debug, type: :boolean, default: false, desc: t('cli.debug')
    define_option :wank, type: :boolean, default: true, desc: t('cli.wank')
  end
end
