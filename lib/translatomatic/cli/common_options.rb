module Translatomatic
  module CLI
    # Defines options common to all command line methods
    class CommonOptions
      include Translatomatic::DefineOptions
      include Translatomatic::Util

      define_option :debug, type: :boolean, default: false,
                            desc: t('cli.debug'), command_line_only: true
      define_option :no_wank, type: :boolean, default: false,
                              desc: t('cli.no_wank')
      define_option :dry_run, type: :boolean, aliases: '-n',
                              desc: t('cli.dry_run'),
                              command_line_only: true
    end
  end
end
