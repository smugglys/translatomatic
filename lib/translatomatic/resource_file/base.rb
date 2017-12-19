require 'pathname'
require 'i18n_data'

class Translatomatic::ResourceFile::Base
  include Translatomatic::Util

  attr_reader :data  # hash of key -> value
  attr_reader :path
  attr_reader :locale
  attr_reader :contents
  attr_reader :format
  attr_reader :properties

  VALID_LANGUAGES = I18nData.languages.keys.collect { |i| i.downcase }.sort

  def initialize(path, locale = nil)
    @path = Pathname.new(path)
    @locale = locale || detect_locale || parse_locale(I18n.default_locale)
    raise "unable to determine locale" unless @locale && @locale.language
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
    false
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

    if basename.match(/_([-\w]{2,})$/i)
      # locale after underscore in filename
      tag = $1
    elsif basename.match(/(^\w{2})$/i)
      # match on entire basename, two letter country code
      # (support for rails en.yml)
      tag = $1
    elsif directory.match(/^([-\w]+)\.lproj$/)
      # xcode localized strings
      tag = $1
    end

    if tag
      locale = parse_locale(tag)
      return locale if valid_language?(locale.language)
    end

    nil
  end

  # test if lang is a valid ISO 639-1 language
  def valid_language?(lang)
    lang.length == 2 && VALID_LANGUAGES.include?(lang.downcase)
  end
end
