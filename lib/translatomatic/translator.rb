require 'translatomatic/translator/base'
require 'translatomatic/translator/yandex'
require 'translatomatic/translator/google'
require 'translatomatic/translator/microsoft'
require 'translatomatic/translator/frengly'
require 'translatomatic/translator/my_memory'

# Provides methods to access and create instances of
# interfaces to translation APIs.
module Translatomatic::Translator

  class << self
    include Translatomatic::Util
  end

  # @return [Class] The translator class corresponding to the given name
  def self.find(name)
    name && !name.empty? ? self.const_get(name) : nil
  end

  # @return [List<Class>] A list of all translator classes
  def self.modules
    self.constants.collect { |c| self.const_get(c) }.select do |klass|
      klass.is_a?(Class) && klass != Translatomatic::Translator::Base
    end
  end

  # @return [List<String>] A list of all translators
  def self.names
    modules.collect { |i| i.name.demodulize }
  end

  # Find all configured translators
  # @param options [Hash<String,String>] Translator options
  # @return [Array<#translate>] A list of translator instances
  def self.available(options = {})
    available = []
    modules.each do |mod|
      begin
        translator = mod.new(options)
        available << translator
      rescue Exception
        log.debug(t("translator.unavailable", name: mod.name.demodulize))
      end
    end
    available
  end

  # @return [String] A description of all translators and options
  def self.list
    out = t("translator.translators") + "\n"
    modules.each do |mod|
      out += "\n" + mod.name.demodulize + ":\n"
      opts = mod.options
      opts.each do |opt|
        optname = opt.name.to_s.gsub("_", "-")
        out += "  --%-18s  %18s  %10s  %15s\n" % [optname, opt.description,
          opt.required ? t("translator.required_option") : "",
          opt.use_env ? "ENV[#{opt.name.upcase}]" : ""]
      end
    end
    out + "\n"
  end

end
