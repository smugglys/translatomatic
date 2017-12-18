require 'translatomatic/translator/yandex.rb'
require 'translatomatic/translator/google.rb'
require 'translatomatic/translator/epworth.rb'

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
