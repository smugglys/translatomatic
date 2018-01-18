module Translatomatic
  module CLI
    # Defines options common to all command line methods
    class CommonOptions
      include Translatomatic::DefineOptions
      include Translatomatic::Util

      define_option :debug, type: :boolean, default: false,
                            desc: t('cli.debug')
      define_option :no_wank, type: :boolean, default: false,
                              desc: t('cli.no_wank')
    end
  end
end
