
module Translatomatic
  # Provides methods to create resource files of various types.
  module ResourceFile
    class << self
      include Translatomatic::Util

      # Load a resource file. If options[:locale] is not specified,
      # the locale of the file will be determined from the filename,
      # or else the current default locale will be used.
      # @param path [String] Path to the resource file
      # @return [Translatomatic::ResourceFile::Base] The resource file, or nil
      #   if the file type is unsupported.
      def load(path, options = {})
        path = path.is_a?(Pathname) ? path : Pathname.new(path)
        types_for_path(path).each do |klass|
          log.debug(t('file.loading', file: path, name: klass.name.demodulize))
          return klass.new(path, options)
        end
        nil
      end

      # Create a new resource file
      def create(path, options = {})
        klass = types_for_path(path).first
        return nil unless klass
        file = klass.new
        file.path = path
        file.locale = locale(options[:locale])
        file
      end

      # Find all resource files under the given directory. Follows symlinks.
      # @param path [String, Pathname] The path to search from
      # @return [Array<Translatomatic::ResourceFile>] Resource files found
      def find(path, options = {})
        files = []
        include_dot_directories = options[:include_dot_directories]
        path = Pathname.new(path) unless path.is_a?(Pathname)
        path.find do |file|
          puts "loading #{file}"
          if !include_dot_directories && file.basename.to_s[0] == '.'
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
      def types
        @types ||= constants.map { |c| const_get(c) }.select do |klass|
          klass.is_a?(Class) && klass != Base && klass < Base
        end
      end

      private

      # find classes that can load the given path by file extension
      def types_for_path(path)
        path = path.is_a?(Pathname) ? path : Pathname.new(path)
        types.select { |klass| klass.enabled? && extension_match(klass, path) }
      end

      def extension_match(klass, path)
        filename = path.basename.to_s.downcase
        klass.extensions.each do |extension|
          # don't match end of line in case file has locale extension
          return true if filename =~ /\.#{extension}/
        end
        false
      end
    end
  end
end

require 'translatomatic/resource_file/base'
require 'translatomatic/resource_file/key_value_support'
require 'translatomatic/resource_file/yaml'
require 'translatomatic/resource_file/properties'
require 'translatomatic/resource_file/text'
require 'translatomatic/resource_file/xml'
require 'translatomatic/resource_file/html'
require 'translatomatic/resource_file/markdown'
require 'translatomatic/resource_file/xcode_strings'
require 'translatomatic/resource_file/plist'
require 'translatomatic/resource_file/resw'
require 'translatomatic/resource_file/subtitle'
require 'translatomatic/resource_file/csv'
require 'translatomatic/resource_file/po'
