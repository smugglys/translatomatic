
module Translatomatic
  # Provides methods to access and create instances of
  # interfaces to translation APIs.
  module Provider
    class << self
      include Translatomatic::Util

      # @return [Class] The provider class corresponding to the given name
      def find(name)
        load_providers
        name && !name.empty? ? const_get(name) : nil
      end

      # Resolve the given list of provider names to a list of providers.
      # If the list is empty, return all providers that are configured.
      # @param list [Array<String>] Provider names or providers
      # @param options [Hash<String,String>] Provider options
      # @return [Array<Translatomatic::Provider::Base>] Providers
      def resolve(list, options = {})
        list = [list].flatten.compact.collect do |provider|
          if provider.respond_to?(:translate)
            provider
          else
            klass = find(provider)
            provider = create_provider(klass, options)
          end
          provider
        end

        # if we didn't resolve to any providers, find all available 
        # providers that work with the given options.
        list.empty? ? available(options) : list
      end

      # @return [List<Class>] A list of all provider classes
      def types
        load_providers
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
        available = types.collect { |klass| create_provider(klass, options) }
        available.compact
      end

      def get_error(name)
        @provider_errors[name]
      end

      private

      def create_provider(klass, options = {})
        klass.new(options) if klass
      rescue StandardError => e
        name = klass.name.demodulize
        log.debug(t('provider.unavailable', name: name))
        provider_error(name, e)
        nil
      end

      def loaded_providers?
        @loaded_providers
      end

      def provider_error(name, e)
        @provider_errors ||= {}
        @provider_errors[name] = e
      end

      def load_providers
        return if loaded_providers?
        Dir[File.join(__dir__, 'provider/*.rb')].sort.each do |file|
          begin
            require file
          rescue StandardError => e
            name = File.basename(file, '.rb').classify
            provider_error(name, e)
          end
        end
        @loaded_providers = true
      end
    end
  end
end
