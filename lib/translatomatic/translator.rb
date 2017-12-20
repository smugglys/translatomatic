require 'translatomatic/translator/base'
require 'translatomatic/translator/yandex'
require 'translatomatic/translator/google'
require 'translatomatic/translator/bing'
require 'translatomatic/translator/frengly'

module Translatomatic::Translator

  def self.find(name)
    instances = all
    instances.find { |i| i.class_name.to_s.downcase.to_sym == name.to_sym }
  end

  def self.modules
    self.constants.select { |c| self.const_get(c).is_a? Class }
  end

  def self.all
    instances = []
    modules.each do |mod|
      begin
        instances << mod.new(config)
      rescue Exception => e
      end
    end
    instances
  end
end
