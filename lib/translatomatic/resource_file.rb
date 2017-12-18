
module Translatomatic
  module ResourceFile

    def self.load(path)
      modules.each do |mod|
        file = mod.new(path)
        return file if file.valid?
      end
      nil
    end

    def self.modules
      self.constants.map { |c| self.const_get(c) }.select do |klass|
        klass.is_a?(Class) && klass != Base
      end
    end
  end
end

require 'translatomatic/resource_file/base'
require 'translatomatic/resource_file/strings'
require 'translatomatic/resource_file/yaml'
require 'translatomatic/resource_file/plist'
require 'translatomatic/resource_file/properties'
