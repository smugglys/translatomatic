
module Translatomatic
  # Provides methods to create resource files of various types.
  module ResourceFile
    class << self
      include Translatomatic::Util
    end

    # Load a resource file. If locale is not specified, the locale of the
    # file will be determined from the filename, or else the current default
    # locale will be used.
    # @param path [String] Path to the resource file
    # @param locale [String] Locale of the resource file
    # @return [Translatomatic::ResourceFile::Base] The resource file, or nil
    #   if the file type is unsupported.
    def self.load(path, locale = nil)
      path = path.kind_of?(Pathname) ? path : Pathname.new(path)
      types_for_path(path).each do |klass|
        log.debug(t("file.loading", file: path, name: klass.name.demodulize))
        return klass.new(path, locale: locale)
      end
      nil
    end

    # Create a new resource file
    def self.create(path, locale = nil)
      klass = const_get(klass_name)
      klass.new
    end

    # Find all resource files under the given directory. Follows symlinks.
    # @param path [String, Pathname] The path to search from
    # @return [Array<Translatomatic::ResourceFile>] Resource files found
    def self.find(path, options = {})
      files = []
      include_dot_directories = options[:include_dot_directories]
      path = Pathname.new(path) unless path.kind_of?(Pathname)
      path.find do |file|
        if !include_dot_directories && file.basename.to_s[0] == ?.
          Find.prune
        else
          resource = load(file)
          files << resource if resource
        end
      end
      files
    end

    # Find all configured resource file classes
    # @return [Array<Class>] Available resource file classes
    def self.types
      @types ||= self.constants.map { |c| self.const_get(c) }.select do |klass|
        klass.is_a?(Class) && klass != Base
      end
    end

    private

    # find classes that can load the given path by file extension
    def self.types_for_path(path)
      path = path.kind_of?(Pathname) ? path : Pathname.new(path)
      types.select { |klass| extension_match(klass, path) }
    end

    def self.extension_match(klass, path)
      filename = path.basename.to_s.downcase
      klass.extensions.each do |extension|
        # don't match end of line in case file has locale extension
        return true if filename.match(/\.#{extension}/)
      end
      false
    end
  end
end

require 'translatomatic/resource_file/base'
require 'translatomatic/resource_file/yaml'
require 'translatomatic/resource_file/properties'
require 'translatomatic/resource_file/text'
require 'translatomatic/resource_file/xml'
require 'translatomatic/resource_file/html'
require 'translatomatic/resource_file/markdown'
require 'translatomatic/resource_file/xcode_strings'
require 'translatomatic/resource_file/plist'
require 'translatomatic/resource_file/resw'
