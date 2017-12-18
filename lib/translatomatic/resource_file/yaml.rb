require 'yaml'

module Translatomatic::ResourceFile
  class YAML < Base

    def initialize(path)
      super(path)
      @format = :yaml
      @language, @region = parse_language_region(path)
      @valid = true
      @properties = read
    end

    def valid?
      @valid
    end

    def set(key, value)
      super(key, value)

      path = key.split(/\./)
      last_key = path.pop
      hash = @data
      path.each { |i| hash = (hash[i] ||= {}) }
      hash[last_key] = value
    end

    def save
      out = @data.to_yaml
      out.sub!(/^---\n/m, '')
      File.open(@path, 'w') { |f| f.puts out }
    end

    private

    def read
      @data = ::YAML.load_file(@path)
      flatten_data(@data)
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
