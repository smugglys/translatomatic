# Utility functions, used internally
module Translatomatic::Util
  private

  # @!visibility private
  module CommonMethods
    private

    def t(key, options = {})
      tkey = "translatomatic.#{key}"
      raise "missing translation: #{tkey}" unless I18n.exists?(tkey)
      I18n.t(tkey, options)
    end
  end

  include CommonMethods

  # @!visibility private
  module ClassMethods
    private

    include CommonMethods
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def log
    Translatomatic.config.logger
  end

  def locale(tag)
    Translatomatic::Locale.parse(tag)
  end

  def string(value, locale)
    Translatomatic::String.new(value, locale)
  end

  def hashify(list)
    hash = {}
    list.each { |i| hash[i.to_s] = i }
    hash
  end
end
