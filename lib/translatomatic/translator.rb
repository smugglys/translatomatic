require 'translatomatic/translator/base'
require 'translatomatic/translator/yandex'
require 'translatomatic/translator/google'
require 'translatomatic/translator/google_web'
require 'translatomatic/translator/microsoft'
require 'translatomatic/translator/frengly'
require 'translatomatic/translator/my_memory'

module Translatomatic
  # Provides methods to access and create instances of
  # interfaces to translation APIs.
  module Translator
    class << self
      include Translatomatic::Util

      # @return [Class] The translator class corresponding to the given name
      def find(name)
        name && !name.empty? ? const_get(name) : nil
      end

      # Resolve the given list of translator names to a list of translators.
      # If the list is empty, return all translators that are configured.
      # @param list [Array<String>] Translator names or translators
      # @param options [Hash<String,String>] Translator options
      # @return [Array<Translatomatic::Translator::Base>] Translators
      def resolve(list, options = {})
        list = [list] unless list.is_a?(Array)
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
          raise t('cli.no_translators') if list.empty?
        end
        list
      end

      # @return [List<Class>] A list of all translator classes
      def types
        constants.collect { |c| const_get(c) }.select do |klass|
          klass.is_a?(Class) && klass != Translatomatic::Translator::Base
        end
      end

      # @return [List<String>] A list of all translators
      def names
        types.collect { |i| i.name.demodulize }
      end

      # Find all configured translators
      # @param options [Hash<String,String>] Translator options
      # @return [Array<#translate>] A list of translator instances
      def available(options = {})
        available = []
        types.each do |klass|
          begin
            translator = klass.new(options)
            available << translator
          rescue StandardError
            log.debug(t('translator.unavailable', name: klass.name.demodulize))
          end
        end
        available
      end

      # @return [String] A description of all translators and options
      def list
        out = t('translator.translators') + "\n\n"
        out += types.collect { |i| translator_description(i) }.join("\n")
        out += "\n"
        out += t('translator.configured') + "\n"
        configured = available(config.all)
        configured.each do |translator|
          out += '  ' + translator.name + "\n"
        end
        out += t('translator.no_translators') if configured.empty?
        out + "\n"
      end

      private

      def translator_description(klass)
        out = klass.name.demodulize + ":\n"
        opts = klass.options || []
        opts.each do |opt|
          args = []
          args << opt.name.to_s.tr('_', '-')
          args << opt.description
          args << opt.required ? t('translator.required_option') : ''
          args << opt.env_name ? "ENV[#{opt.env_name}]" : ''
          out += format("  --%-18s  %18s  %10s  %15s\n", *args)
        end
        out
      end

      def config
        Translatomatic.config
      end
    end
  end
end
