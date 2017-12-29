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

  # Create a new resource file.
  # If locale is unspecified, attempts to determine the locale of the file
  # automatically, and if that fails, uses the default locale.
  # @param path [String] Path to the file
  # @param locale [String] Locale of the file contents
  # @return [Translatomatic::ResourceFile::Base] the resource file.
  def initialize(path, locale = nil)
    @path = path.kind_of?(Pathname) ? path : Pathname.new(path)
    @locale = Translatomatic::Locale.parse(locale || detect_locale || Translatomatic::Locale.default)
    raise t("resource.unknown_locale") unless @locale && @locale.language
    @valid = false
    @properties = {}
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

  # Test if the current resource file is valid
  # @return true if the current file is valid
  def valid?
    @valid
  end

  # Save the resource file.
  # @param target [Pathname] The destination path
  # @param options [Hash<Symbol, Object>] Output format options
  # @return [void]
  def save(target = path, options = {})
    raise "save(path) must be implemented by subclass"
  end

  # @return [String] String representation of this file
  def to_s
    "#{path.basename.to_s} (#{locale})"
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

  # @return [boolean] true if this resource file supports variable interpolation
  def supports_variable_interpolation?
    false
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

  def created_by
    t("resource.created_by", app: "Translatomatic",
      version: Translatomatic::VERSION,
      date: I18n.l(DateTime.now, format: :short))
  end

  # detect locale from filename
  def detect_locale
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

end
