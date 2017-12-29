# Utility functions, used internally
module Translatomatic::Util

  private

  # @!visibility private
  module ClassMethods
    private
    def t(key, options = {})
      I18n.t("translatomatic.#{key}", options)
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def log
    Translatomatic::Config.instance.logger
  end

  def locale(tag)
    Translatomatic::Locale.parse(tag)
  end

  def string(value, locale)
    Translatomatic::String.new(value, locale)
  end

  def t(key, options = {})
    I18n.t("translatomatic.#{key}", options)
  end
end
