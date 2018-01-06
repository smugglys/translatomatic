module Translatomatic::CLI
  # File conversion functions for the command line interface
  class Convert < Base

    desc "convert source target", t("cli.convert.convert")
    # Convert a resource file from one format to another
    # @param source [String] An existing resource file
    # @param target [String] The name of a target resource file
    # @return [void]
    def convert(source, target)
      run do
        converter = Translatomatic::Converter.new
        converter.convert(source, target)
      end
    end
  end

end
