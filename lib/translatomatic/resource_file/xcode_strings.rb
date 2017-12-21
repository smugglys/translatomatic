module Translatomatic::ResourceFile

  # XCode strings file
  class XCodeStrings < Base

    def self.extensions
      %w{strings}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path)
      @format = :strings
      @valid = true
      @text = @path.exist? ? @path.read : nil
      @properties = { text: @text }
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
    # @note localization files in XCode use the following file name
    #   convention: Project/locale.lproj/filename
    def locale_path(locale)
      if path.to_s.match(/\/([-\w]+).lproj\/.+.strings$/)
        # xcode style
        filename = path.basename
        path.parent.parent + (locale.to_s + ".lproj") + filename
      else
        super(locale)
      end
    end

  end
end
