require 'yaml'

module Translatomatic::ResourceFile
  # YAML resource file
  # @see http://www.yaml.org/
  class YAML < Base

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{yml yaml}
    end

    # (see Translatomatic::ResourceFile::Base.is_key_value?)
    def self.is_key_value?
      true
    end

    # (see Translatomatic::ResourceFile::Base.supports_variable_interpolation?)
    def self.supports_variable_interpolation?
      true
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
    # @note localization files in rails use the following file name
    #   convention: config/locales/en.yml.
    def locale_path(locale)
      if path.to_s.match(/config\/locales\/[-\w]+.yml$/)
        # rails style
        filename = locale.to_s + path.extname
        path.dirname + filename
      else
        super(locale)
      end
    end

    # (see Translatomatic::ResourceFile::Base#set)
    def set(key, value)
      super(key, value)

      hash = @data
      path = key.to_s.split(/\./)
      last_key = path.pop
      path.each { |i| hash = (hash[i] ||= {}) }
      hash[last_key] = value
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      if @data
        data = @data
        data = data.transform_keys { locale.language } if ruby_i18n?
        out = data.to_yaml
        out.sub!(/^---\n/m, '')
        out = comment(created_by) + "\n" + out unless options[:no_created_by]
        target.write(out)
      end
    end

    # (see Translatomatic::ResourceFile::Base#create_variable)
    def create_variable(name)
      return "%{#{name}}"
    end

    # (see Translatomatic::ResourceFile::Base#variable_regex)
    def variable_regex
      /\%\s*\{.*?\}/
    end

    private

    def init
      # yaml data
      @data = {}
    end

    def load
      @data = ::YAML.load_file(path.to_s) || {}
      @properties = flatten(@data)
    end

    # true if this resource file looks like a ruby i18n data file.
    def ruby_i18n?
      if @data && @data.length == 1
        lang = @data.keys[0]
        Translatomatic::Locale.new(lang).valid?
      end
    end

    def comment(text)
      "# #{text}\n"
    end

  end
end
