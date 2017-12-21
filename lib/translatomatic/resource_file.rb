
module Translatomatic
  module ResourceFile
    class << self
      include Translatomatic::Util
    end

    # Load a resource file. If locale is not specified, the locale of the
    # file will be determined from the filename, or else the current default
    # locale will be used.
    # @param [String] path Path to the resource file
    # @param [String] locale Locale of the resource file
    # @return [Translatomatic::ResourceFile::Base] The resource file, or nil
    #   if the file type is unsupported.
    def self.load(path, locale = nil)
      modules.each do |mod|
        # match on entire filename to support extensions containing locales
        if extension_match(mod, path)
          log.debug("attempting to load #{path} using #{mod.name.demodulize}")
          file = mod.new(path, locale)
          return file if file.valid?
        end
      end
      nil
    end

    # Find all resource files under the given directory. Follows symlinks.
    # @param [String, Pathname] path The path to search from
    # @return [Array<Translatomatic::ResourceFile>] Resource files found
    def self.find(path)
      path = Pathname.new(path) unless path.kind_of?(Pathname)
      path.find do |file|
        puts file
      end
    end

    # Find all configured resource file classes
    # @return [Array<Class>] Available resource file classes
    def self.modules
      self.constants.map { |c| self.const_get(c) }.select do |klass|
        klass.is_a?(Class) && klass != Base
      end
    end

    private

    def self.extension_match(mod, path)
      filename = Pathname.new(path).basename.to_s.downcase
      mod.extensions.each do |extension|
        return true if filename.match(/\.#{extension}/)
      end
      false
    end
  end
end

require 'translatomatic/resource_file/base'
require 'translatomatic/resource_file/yaml'
require 'translatomatic/resource_file/plist'
require 'translatomatic/resource_file/properties'
require 'translatomatic/resource_file/text_file'
require 'translatomatic/resource_file/html_file'
require 'translatomatic/resource_file/xcode_strings'
