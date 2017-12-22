module Translatomatic::ResourceFile
  class HTML < XML

    def self.extensions
      %w{html htm shtml}
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
    def locale_path(locale)
      extlist = extension_list
      if extlist.length >= 2 && loc_idx = find_locale(extlist)
        # part of the extension is the locale
        # replace that part with the new locale
        extlist[loc_idx] = locale.to_s
        new_extension = extlist.join(".")
        return strip_extensions.sub_ext("." + new_extension)
      else
        # add locale extension
        ext = path.extname
        path.sub_ext("#{ext}." + locale.to_s)
      end

      # fall back to base functionality
      #super(locale)
    end

    # (see Translatomatic::ResourceFile::Base#save(path))
    def save(target = path)
      target.write(@doc.to_html) if @doc
    end

  end
end
