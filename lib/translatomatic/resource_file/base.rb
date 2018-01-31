module Translatomatic
  module ResourceFile
    # Base class for resource file implementations
    # @abstract Subclasses implement different types of resource files
    class Base
      include DefineOptions

      # @return [Hash<Symbol,Object] Options used in the constructor
      attr_reader :options

      # @return [Locale] The locale of the contents of this resource file
      attr_accessor :locale

      # @return [Pathname] The path to this resource file
      attr_accessor :path

      # @return [boolean] True if this resource format is enabled
      def self.enabled?
        true
      end

      # @return [Array<String>] File extensions supported by this resource file
      def self.extensions
        raise 'extensions must be implemented by subclass'
      end

      # @return [boolean] True if the file format consists of keys and values
      def self.key_value?
        false
      end

      # @return [boolean] true if this resource file supports
      #   variable interpolation
      def self.supports_variable_interpolation?
        false
      end

      # Create a new resource file or load an existing file.
      # If options[:locale] is unspecified, attempts to determine
      # the locale of the file automatically, and if that fails,
      # uses the default locale.
      # Raises an exception if errors were encountered loading the file.
      # @param path [String] Path to the file
      # @param options [Hash<Symbol,String>] Options
      # @return [Translatomatic::ResourceFile::Base] the resource file.
      def initialize(path = nil, options = {})
        raise 'expected options hash' if options && !options.is_a?(Hash)
        raise t('file.unsupported', file: path) unless self.class.enabled?
        @options = options || {}
        @properties = {}
        @metadata = Metadata.new
        @path = path.nil? || path.is_a?(Pathname) ? path : Pathname.new(path)
        update_locale
        init
        if @path
          raise t('file.not_found') unless @path.exist?
          load
        end
      end

      # Save the resource file.
      # @param target [Pathname] The destination path
      # @param options [Hash<Symbol, Object>] Output format options
      # @return [void]
      def save(target = path, options = {})
        raise 'save(path) must be implemented by subclass'
      end

      # @return [Symbol] The type of this resource file, e.g. ":properties"
      def type
        self.class.name.demodulize.downcase.to_sym
      end

      # Create a path for the current resource file with a given locale
      # @param target_locale [String] The target locale
      # @return [Pathname] The path of this resource file modified
      #   for the given locale
      def locale_path(target_locale)
        modify_path_locale(path, target_locale)
      end

      # Set all properties
      # @param properties [Hash<String,String>] New properties
      def properties=(properties)
        # use set rather that set @properties directly as subclasses
        # override set()
        properties.each do |key, value|
          set(key, value)
        end
      end

      # @return [Hash<String,String>] key -> value properties
      def properties
        @properties.dup
      end

      # Get the value of a property
      # @param key [String] The name of the property
      # @return [String] The value of the property
      def get(key)
        @properties[key]
      end

      # Get context of a property
      # @param key [String] The name of the property
      # @return [Array<String>] The property context, may be nil
      def get_context(key)
        @metadata.get_context(key)
      end

      # Set a property
      # @param key [String] The name of the property
      # @param value [String] The new value of the property
      # @return [String] The new value of the property
      def set(key, value)
        @properties[key] = value
      end

      # @return [String] String representation of this file
      def to_s
        relative_path(path).to_s
      end

      # @return [Array<Text>] All property values split into sentences
      def sentences
        sentences = []
        properties.each_value do |value|
          string = build_text(value, locale)
          sentences += string.sentences
        end
        sentences
      end

      # Create an interpolated variable string.
      # @param name [String] The variable name
      # @return [String] A string representing the interpolated variable, or
      #   nil if this resource file doesn't support variable interpolation.
      def create_variable(name)
        return nil unless self.class.supports_variable_interpolation?
        raise 'create_variable(name) must be implemented by subclass'
      end

      # @return [Regexp] A regexp used to match interpolated variables
      def variable_regex
        return nil unless self.class.supports_variable_interpolation?
        raise 'variable_regex must be implemented by subclass'
      end

      private

      include Translatomatic::Util
      include Translatomatic::Flattenation
      include Translatomatic::PathUtils

      # called by constructor before load
      def init; end

      # load contents from @path
      def load
        raise 'load must be implemented by subclass'
      end

      def update_locale
        default = Translatomatic::Locale.default
        locale = @options[:locale] || detect_path_locale(path) || default
        @locale = Translatomatic::Locale.parse(locale)
        raise t('file.unknown_locale') unless @locale && @locale.language
      end

      def created_by
        options = {
          app: 'Translatomatic',
          version: Translatomatic::VERSION,
          date: I18n.l(Time.now),
          locale: locale.language,
          url: Translatomatic::URL
        }
        t('file.created_by', options)
      end

      def created_by?
        @created_by
      end

      def parsing_error(error)
        raise StandardError, error
      end
    end
  end
end
