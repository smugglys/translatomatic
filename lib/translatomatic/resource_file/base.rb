require 'pathname'

class Translatomatic::ResourceFile::Base
  include Translatomatic::Util

  attr_reader :data  # hash of key -> value
  attr_reader :path
  attr_reader :locale
  attr_reader :contents
  attr_reader :format
  attr_reader :properties

  def initialize(path, locale = nil)
    @path = Pathname.new(path)
    @locale = locale || detect_locale || parse_locale(I18n.default_locale)
    raise "unable to determine locale" unless @locale && @locale.language
    @valid = false
    @properties = {}
  end

  # return path for the current resource file with a given locale
  def locale_path(locale)
    filename = path.basename.sub_ext('').sub(/_.*?$/, '').to_s
    filename += "_" + locale.to_s + path.extname
    path.dirname + filename
  end

  def get(name)
    @properties[name]
  end

  def set(key, value)
    @properties[key] = value
  end

  def valid?
    @valid
  end

  def save
    raise "save must be implemented by subclass"
  end

  def to_s
    "path #{path}, format: #{format}, locale: #{locale}"
  end

  private

  # detect locale from filename
  def detect_locale
    tag = nil
    basename = path.sub_ext('').basename.to_s
    directory = path.dirname.basename.to_s
    extlist = extension_list(path)

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

  # for index.html.de, returns ['html', 'de']
  def extension_list
    idx = path.basename.to_s.index('.')
    idx ? path.basename.to_s[idx..-1].split('.') : []
  end

end
