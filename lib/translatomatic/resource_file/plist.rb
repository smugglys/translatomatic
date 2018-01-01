module Translatomatic::ResourceFile
  # Property list resource file
  # @see https://en.wikipedia.org/wiki/Property_list
  class Plist < XML
    include Translatomatic::ResourceFile::XCodeStringsLocalePath

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{plist}
    end

    private

    def text_nodes_xpath
      '//*[not(self::key)]/text()'
    end

  end # class
end   # module
