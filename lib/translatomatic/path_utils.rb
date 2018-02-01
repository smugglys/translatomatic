module Translatomatic
  # Utilities for locales and paths
  module PathUtils
    # Find a new path representing the given path with a new locale
    # @param path [Pathname] The current path
    # @param target_locale [String] The target locale
    # @return [Pathname] The new path for the given locale
    def modify_path_locale(path, target_locale, preferred_separator = '.')
      basename = basename_stripped(path)

      extlist = extension_list(path)
      if extlist.length >= 2 && (loc_idx = find_extension_locale(extlist))
        # extension(s) contains locale, replace it
        extlist[loc_idx] = target_locale.to_s
        filename = basename + '.' + extlist.join('.')
        path.dirname + filename
      elsif valid_locale?(basename)
        # basename is a locale name, replace it
        path.dirname + (target_locale.to_s + path.extname)
      elsif basename.match(/_([-\w]+)\Z/) &&
            valid_locale?(Regexp.last_match(1))
        # basename contains locale, e.g. basename_$locale.ext
        add_basename_locale(path, target_locale, '_') # retain _
      elsif valid_locale?(path.parent.basename(path.parent.extname)) ||
            path.parent.basename.to_s == 'Base.lproj'
        # parent directory contains locale, e.g. strings/en-US/text.resw
        # or project/en.lproj/Strings.strings
        path.parent.parent + (target_locale.to_s +
          path.parent.extname) + path.basename
      elsif path.to_s =~ %r{\bres/values([-\w]+)?/.+$}
        # android strings
        filename = path.basename
        path.parent.parent + ('values-' + target_locale.to_s) + filename
      else
        # default behaviour, add locale after separator in basename
        add_basename_locale(path, target_locale, preferred_separator)
      end
    end

    # detect locale from path
    def detect_path_locale(path)
      return nil unless path
      tag = nil
      basename = path.sub_ext('').basename.to_s
      directory = path.dirname.basename.to_s
      extlist = extension_list(path)

      if basename.match(/_([-\w]{2,})$/) &&
         valid_locale?(Regexp.last_match(1))
        # locale after underscore in filename
        tag = Regexp.last_match(1)
      elsif directory =~ /^([-\w]+)\.lproj$/
        # xcode localized strings
        tag = Regexp.last_match(1)
      elsif extlist.length >= 2 && (loc_idx = find_extension_locale(extlist))
        # multiple parts to extension, e.g. index.html.en
        tag = extlist[loc_idx]
      elsif valid_locale?(basename)
        # try to match on entire basename
        # (support for rails en.yml)
        tag = basename
      elsif valid_locale?(path.parent.basename)
        # try to match on parent directory, e.g. strings/en-US/text.resw
        tag = path.parent.basename
      elsif path.parent.basename.to_s.match(/-([-\w]+)/) &&
            valid_locale?(Regexp.last_match(1))
        # try to match on trailing part of parent directory,
        # e.g. res/values-en/strings.xml
        tag = Regexp.last_match(1)
      end

      tag ? Translatomatic::Locale.parse(tag, true) : nil
    end

    private

    def read_contents(path)
      Translatomatic::Slurp.read(path.to_s)
    end

    # ext_sub() only removes the last extension
    def basename_stripped(path)
      filename = path.basename.to_s
      filename.sub!(/\..*$/, '')
      filename
    end

    def relative_path(path)
      if path.relative?
        path
      else
        path.relative_path_from(Pathname.pwd)
      end
    end

    # for index.html.de, returns ['html', 'de']
    def extension_list(path)
      filename = path.basename.to_s
      idx = filename.index('.')
      if idx && idx < filename.length - 1
        filename[idx + 1..-1].split('.')
      else
        []
      end
    end

    def add_basename_locale(path, target_locale, preferred_separator = '.')
      # remove any underscore and trailing text from basename
      deunderscored = basename_stripped(path).sub(/_.*?\Z/, '')
      # add #{preferred_separator}locale.ext
      filename = deunderscored + preferred_separator + 
                 target_locale.to_s + path.extname
      path.dirname + filename
    end

    # test if the list of strings contains a valid locale
    # return the index to the locale, or nil if no locales found
    def find_extension_locale(extlist)
      extlist.find_index { |i| valid_locale?(i) }
    end

    def valid_locale?(tag)
      Translatomatic::Locale.new(tag).valid?
    end
  end
end
