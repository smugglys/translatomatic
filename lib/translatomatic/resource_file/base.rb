# @abstract Subclasses implement different types of resource files
class Translatomatic::ResourceFile::Base

  attr_accessor :locale
  attr_reader :path
  attr_reader :contents
  attr_reader :format

  # @return [Hash<String,String>] key -> value properties
  attr_reader :properties

  # Create a new resource file.
  # If locale is unspecified, attempts to determine the locale of the file
  # automatically, and if that fails, uses the default locale.
  # @param [String] path Path to the file
  # @param [String] locale Locale of the file contents
  # @return [Translatomatic::ResourceFile::Base] the resource file.
  def initialize(path, locale = nil)
    @path = Pathname.new(path)
    @locale = locale || detect_locale || parse_locale(I18n.default_locale)
    raise "unable to determine locale" unless @locale && @locale.language
    @valid = false
    @properties = {}
  end

  # Create a path for the current resource file with a given locale
  # @param [String] locale for the path
  # @return [Pathname] The path of this resource file modified for the given locale
  def locale_path(locale)
    filename = path.basename.sub_ext('').sub(/_.*?$/, '').to_s
    filename += "_" + locale.to_s + path.extname
    path.dirname + filename
  end

  # Get the value of a property
  # @param [String] name The name of the property
  # @return [String] The value of the property
  def get(name)
    @properties[name]
  end

  # Set a property
  # @param [String] key The name of the property
  # @param [String] value The new value of the property
  # @return [String] The new value of the property
  def set(name, value)
    @properties[name] = value
  end

  # Test if the current file is valid
  # @return true if the current file is valid
  def valid?
    @valid
  end

  # Save properties to the file
  # @return [void]
  def save
    raise "save must be implemented by subclass"
  end

  # @return [String] String representation of this file
  def to_s
    "#{path.basename.to_s} (#{locale})"
  end

  private

  include Translatomatic::Util

  # detect locale from filename
  def detect_locale
    tag = nil
    basename = path.sub_ext('').basename.to_s
    directory = path.dirname.basename.to_s
    extlist = extension_list

    if basename.match(/_([-\w]{2,})$/i)
      # locale after underscore in filename
      tag = $1
    elsif basename.match(/^(\w{2})$/i) && valid_locale?($1)
      # match on entire basename, two letter country code
      # (support for rails en.yml)
      tag = $1
    elsif directory.match(/^([-\w]+)\.lproj$/)
      # xcode localized strings
      tag = $1
    elsif extlist.length >= 2 && valid_locale?(extlist[-1])
      # multiple parts to extension, e.g. index.html.en
      tag = extlist[-1]
    end

    tag ? parse_locale(tag, true) : nil
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
