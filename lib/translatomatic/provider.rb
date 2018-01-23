require 'translatomatic/provider/base'
require 'translatomatic/provider/yandex'
require 'translatomatic/provider/google'
require 'translatomatic/provider/google_web'
require 'translatomatic/provider/microsoft'
require 'translatomatic/provider/frengly'
require 'translatomatic/provider/my_memory'

module Translatomatic
  # Provides methods to access and create instances of
  # interfaces to translation APIs.
  module Provider
    class << self
      include Translatomatic::Util

      # @return [Class] The provider class corresponding to the given name
      def find(name)
        name && !name.empty? ? const_get(name) : nil
      end

      # Resolve the given list of provider names to a list of providers.
      # If the list is empty, return all providers that are configured.
      # @param list [Array<String>] Provider names or providers
      # @param options [Hash<String,String>] Provider options
      # @return [Array<Translatomatic::Provider::Base>] Providers
      def resolve(list, options = {})
        list = [list] unless list.is_a?(Array)
        list = list.compact.collect do |provider|
          if provider.respond_to?(:translate)
            provider
          else
            klass = Translatomatic::Provider.find(provider)
            provider = klass.new(options)
          end
          provider
        end

        if list.empty?
          # find all available providers that work with the given options
          list = Translatomatic::Provider.available(options)
          raise t('cli.no_providers') if list.empty?
        end
        list
      end

      # @return [List<Class>] A list of all provider classes
      def types
        constants.collect { |c| const_get(c) }.select do |klass|
          klass.is_a?(Class) && klass != Translatomatic::Provider::Base
        end
      end

      # @return [List<String>] A list of all providers
      def names
        types.collect { |i| i.name.demodulize }
      end

      # Find all configured providers
      # @param options [Hash<String,String>] Provider options
      # @return [Array<#translate>] A list of provider instances
      def available(options = {})
        available = []
        types.each do |klass|
          begin
            provider = klass.new(options)
            available << provider
          rescue StandardError
            log.debug(t('provider.unavailable', name: klass.name.demodulize))
          end
        end
        available
      end
    end
  end
end
