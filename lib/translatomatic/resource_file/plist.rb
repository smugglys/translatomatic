module Translatomatic::ResourceFile
  class Plist < XML

    def self.extensions
      %w{plist}
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
    # @note localization files in XCode use the following file name
    #   convention: Project/locale.lproj/filename
    # @todo refactor this and xcode_strings.rb to use the same code
    def locale_path(locale)
      if path.to_s.match(/\/([-\w]+).lproj\/.+.plist$/)
        # xcode style
        filename = path.basename
        path.parent.parent + (locale.to_s + ".lproj") + filename
      else
        super(locale)
      end
    end

    private

    def text_nodes_xpath
      '//*[not(self::key)]/text()'
    end

  end # class
end   # module
