module Translatomatic::ResourceFile
  class RESW < XML

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{resw}
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
    def locale_path(locale)
      # e.g. strings/en-US/resources.resw
      dir = path.dirname
      dir.parent + locale.to_s + path.basename
    end

    private

    def create_nodemap(doc)
      result = {}
      key_values = doc.search('//data/@name|//text()')
      key_values.each_slice(2) do |key, value|
        key = key.value
        value = value
        result[key] = value
      end
      result
    end

  end # class
end   # module
