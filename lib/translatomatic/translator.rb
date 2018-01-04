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

  # Resolve the given list of translator names to a list of translators.
  # If the list is empty, return all translators that are configured.
  # @param list [Array<String>] Translator names or translators
  # @param options [Hash<String,String>] Translator options
  # @return [Array<Translatomatic::Translator::Base>] Translators
  def self.resolve(list, options = {})
    list = [list] unless list.kind_of?(Array)
    list = list.compact.collect do |translator|
      if translator.respond_to?(:translate)
        translator
      else
        klass = Translatomatic::Translator.find(translator)
        translator = klass.new(options)
      end
      translator
    end

    if list.empty?
      # find all available translators that work with the given options
      list = Translatomatic::Translator.available(options)
      if list.empty?
        raise t("cli.no_translators")
      end
    end
    list
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
          opt.env_name ? "ENV[#{opt.env_name}]" : ""]
      end
    end
    out += "\n"
    out += t("translator.configured") + "\n"
    configured = available
    configured.each do |translator|
      out += "  " + translator.name + "\n"
    end
    out += t("translator.no_translators") if configured.empty?
    out + "\n"
  end

end
