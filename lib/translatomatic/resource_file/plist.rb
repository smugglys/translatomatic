module Translatomatic::ResourceFile
  class Plist < Base

    def self.extensions
      %w{plist}
    end

    def initialize(path, locale = nil)
      super(path)
      @valid = true
      @format = :plist
      @properties = {} #@path.exist? ? read(@path) : {}
    end

    # localization files in XCode use the following file name convention:
    # Project/locale.lproj/filename
    # TODO: refactor this and xcode_strings.rb to use the same code
    def locale_path(locale)
      if path.to_s.match(/\/([-\w]+).lproj\/.+.plist$/)
        # xcode style
        filename = path.basename
        path.parent.parent + (locale.to_s + ".lproj") + filename
      else
        super(locale)
      end
    end

  end
end
