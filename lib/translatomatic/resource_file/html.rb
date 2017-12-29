module Translatomatic::ResourceFile
  # HTML resource file
  class HTML < XML

    # (see Translatomatic::ResourceFile::Base.extensions)
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
        # TODO: need configurable order for locale & ext here?
        #path.sub_ext("#{ext}." + locale.to_s)
        path.sub_ext("." + locale.to_s + ext)
      end
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      if @doc
        add_created_by unless options[:no_created_by]
        target.write(@doc.to_html)
      end
    end

    private

    def text_nodes_xpath
      '//*[not(self::code)]/text()'
    end

    def read_doc(path)
      Nokogiri::HTML(path.open) do |config|
        config.noblanks
      end
    end
  end
end
