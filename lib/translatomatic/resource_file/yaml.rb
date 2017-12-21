require 'yaml'

module Translatomatic::ResourceFile
  class YAML < Base

    def self.extensions
      %w{yml yaml}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path)
      @format = :yaml
      @valid = true
      @data = {}
      @properties = @path.exist? ? read : {}
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

      path = key.split(/\./)
      last_key = path.pop
      hash = @data
      path.each { |i| hash = (hash[i] ||= {}) }
      hash[last_key] = value
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save
      out = @data.to_yaml
      out.sub!(/^---\n/m, '')
      path.write(out)
    end

    private

    def read
      begin
        @data = ::YAML.load_file(@path)
        flatten_data(@data)
      rescue Exception
        @valid = false
        {}
      end
    end

    def flatten_data(data)
      result = {}
      unless data.kind_of?(Hash)
        @valid = false
        return {}
      end
      data.each do |key, value|
        if value.kind_of?(Hash)
          children = flatten_data(value)
          children.each do |ck, cv|
            result[key + "." + ck] = cv
          end
        else
          result[key] = value
        end
      end
      result
    end
  end
end
