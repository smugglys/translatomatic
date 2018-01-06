# Base class for resource file implementations
# @abstract Subclasses implement different types of resource files
class Translatomatic::ResourceFile::Base

  attr_accessor :locale
  attr_accessor :path

  # @return [Hash<String,String>] key -> value properties
  attr_reader :properties

  # @return [Array<String>] File extensions supported by this resource file
  def self.extensions
    raise "extensions must be implemented by subclass"
  end

  # @return [boolean] True if the file format consists of keys and values
  def self.is_key_value?
    false
  end

  # @return [boolean] true if this resource file supports variable interpolation
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
    raise "expected options hash" if options && !options.kind_of?(Hash)
    @options = options || {}
    @properties = {}
    @path = path.nil? || path.kind_of?(Pathname) ? path : Pathname.new(path)
    update_locale
    init
    load if @path && @path.exist?
  end

  # Save the resource file.
  # @param target [Pathname] The destination path
  # @param options [Hash<Symbol, Object>] Output format options
  # @return [void]
  def save(target = path, options = {})
    raise "save(path) must be implemented by subclass"
  end

  # @return [String] The format of this resource file, e.g. "Properties"
  def format
    self.class.name.demodulize.downcase.to_sym
  end

  # Create a path for the current resource file with a given locale
  # @param locale [String] The target locale
  # @return [Pathname] The path of this resource file modified for the given locale
  def locale_path(locale)
    basename = path.sub_ext('').basename.to_s

    extlist = extension_list
    if extlist.length >= 2 && loc_idx = find_locale(extlist)
      # extension(s) contains locale, replace it
      extlist[loc_idx] = locale.to_s
    elsif valid_locale?(basename)
      # basename is a locale name, replace it
      path.dirname + (locale.to_s + path.extname)
    else
      # remove any underscore and trailing text from basename
      deunderscored = basename.sub(/_.*?$/, '')
      # add _locale.ext
      filename = deunderscored + "_" + locale.to_s + path.extname
      path.dirname + filename
    end
  end

  # Set all properties
  # @param properties [Hash<String,String>] New properties
  def properties=(properties)
    # use set rather that set @properties directly as subclasses override set()
    properties.each do |key, value|
      set(key, value)
    end
  end

  # Get the value of a property
  # @param key [String] The name of the property
  # @return [String] The value of the property
  def get(key)
    @properties[key]
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
    path.basename.to_s
  end

  def type
    self.class.name.demodulize
  end

  # @return [Array<String>] All property values split into sentences
  def sentences
    sentences = []
    properties.values.each do |value|
      string = Translatomatic::String.new(value, locale)
      sentences += string.sentences
    end
    sentences
  end

  # Create an interpolated variable string.
  # @return [String] A string representing the interpolated variable, or
  #   nil if this resource file doesn't support variable interpolation.
  def create_variable(name)
    return nil unless supports_variable_interpolation?
    raise "create_variable(name) must be implemented by subclass"
  end

  # @return [Regexp] A regexp used to match interpolated variables
  def variable_regex
    return nil unless supports_variable_interpolation?
    raise "variable_regex must be implemented by subclass"
  end

  private

  include Translatomatic::Util

  # called by constructor before load
  def init
  end

  # load contents from @path
  def load
    raise "load must be implemented by subclass"
  end

  def update_locale
    locale = @options[:locale] || detect_locale || Translatomatic::Locale.default
    @locale = Translatomatic::Locale.parse(locale)
    raise t("file.unknown_locale") unless @locale && @locale.language
  end

  def created_by
    t("file.created_by", app: "Translatomatic",
      version: Translatomatic::VERSION, date: I18n.l(DateTime.now),
      locale: locale.language
    )
  end

  def read_contents(path)
    File.read(path.to_s, mode: "r:bom|utf-8")
  end

  def parsing_error(error)
    raise Exception.new(error)
  end

  # detect locale from filename
  def detect_locale
    return nil unless path
    tag = nil
    basename = path.sub_ext('').basename.to_s
    directory = path.dirname.basename.to_s
    extlist = extension_list

    if basename.match(/_([-\w]{2,})$/i)
      # locale after underscore in filename
      tag = $1
    elsif directory.match(/^([-\w]+)\.lproj$/)
      # xcode localized strings
      tag = $1
    elsif extlist.length >= 2 && loc_idx = find_locale(extlist)
      # multiple parts to extension, e.g. index.html.en
      tag = extlist[loc_idx]
    elsif valid_locale?(basename)
      # try to match on entire basename
      # (support for rails en.yml)
      tag = basename
    elsif valid_locale?(path.parent.basename)
      # try to match on parent directory, e.g. strings/en-US/text.resw
      tag = path.parent.basename
    end

    tag ? Translatomatic::Locale.parse(tag, true) : nil
  end

  def valid_locale?(tag)
    Translatomatic::Locale.new(tag).valid?
  end

  # test if the list of strings contains a valid locale
  # return the index to the locale, or nil if no locales found
  def find_locale(list)
    list.find_index { |i| valid_locale?(i) }
  end

  # ext_sub() only removes the last extension
  def strip_extensions
    filename = path.basename.to_s
    filename.sub!(/\..*$/, '')
    path.parent + filename
  end

  # for index.html.de, returns ['html', 'de']
  def extension_list
    filename = path.basename.to_s
    idx = filename.index('.')
    idx && idx < filename.length - 1 ? filename[idx + 1..-1].split('.') : []
  end

  # flatten hash or array of data to a hash of key => value pairs
  def flatten(data)
    result = {}

    if data.kind_of?(Hash)
      data.each do |key, value|
        flatten_add(result, key, value)
      end
    elsif data.kind_of?(Array)
      data.each_with_index do |value, i|
        key = "key" + i.to_s
        flatten_add(result, key, value)
      end
    end

    result
  end

  def flatten_add(result, key, value)
    if needs_flatten?(value)
      children = flatten(value)
      children.each do |ck, cv|
        result[key + "." + ck] = cv
      end
    else
      result[key] = value
    end
  end

  def needs_flatten?(value)
    value.kind_of?(Array) || value.kind_of?(Hash)
  end
end
