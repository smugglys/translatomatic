module Translatomatic::CLI
  # Defines options common to all command line methods
  class CommonOptions
    private

    include Translatomatic::DefineOptions
    include Translatomatic::Util

    define_options(
      { name: :debug, type: :boolean, default: false, desc: t('cli.debug') },
      { name: :wank, type: :boolean, default: true, desc: t('cli.wank') }
    )
  end
end
