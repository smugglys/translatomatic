require 'translatomatic/translator/base'
require 'translatomatic/translator/yandex'
require 'translatomatic/translator/google'
require 'translatomatic/translator/bing'
require 'translatomatic/translator/frengly'

module Translatomatic::Translator

  def self.find(name)
    self.const_get(name)
  end

  def self.modules
    self.constants.collect { |c| self.const_get(c) }.select do |klass|
      klass.is_a?(Class) && klass != Translatomatic::Translator::Base
    end
  end

  def self.names
    modules.collect { |i| i.name.demodulize }
  end

  def self.list
    out = "Translators available:\n"
    modules.each do |mod|
      out += "\n" + mod.name.demodulize + ":\n"
      opts = mod.options
      opts.each do |opt|
        out += "  --%-18s  %15s  %10s  %15s\n" % [opt.name, opt.description,
          opt.required ? "(required)" : "",
          opt.use_env ? "ENV[#{opt.name.upcase}]" : ""]
      end
    end
    out + "\n"
  end

end
