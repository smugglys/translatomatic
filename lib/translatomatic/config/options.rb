module Translatomatic
  module Config
    # A collection of all translatomatic options available
    module Options
      class << self
        # @return [Hash<String,Translatomatic::Option>] options
        def options
          @config_options ||= begin
            # create mapping from option name to option object
            map = {}
            config_sources.each do |source|
              map.merge!(source_options(source))
            end
            map
          end
        end

        # @param key [Symbol] Option name
        # @return [Translatomatic::Option] The specified option
        def option(key)
          check_valid_key(key)
          options[key.to_sym]
        end

        # Test if key is a recognised configuration option name.
        # Raise an exception if it isn't
        # @param key [Symbol] Option name
        def check_valid_key(key)
          key = key ? key.to_sym : nil
          raise t('config.invalid_key', key: key) unless valid_key?(key)
          key
        end

        # @return [Boolean] True if key is a recognised configuration option
        def valid_key?(key)
          options.include?(key)
        end

        private

        include Translatomatic::Util

        def config_sources
          [
            Translatomatic::CLI::CommonOptions,
            Translatomatic::CLI::Translate,
            Translatomatic::CLI::Config,
            Translatomatic::Provider.types,
            Translatomatic::ResourceFile.types,
            Translatomatic::Database,
            Translatomatic::Converter
          ].freeze
        end

        def source_options(source)
          map = {}
          source_options = Translatomatic::Option.options_from_object(source)
          source_options.each do |sopt|
            optname = sopt.name.to_sym
            map[optname] = sopt
          end
          map
        end
      end
    end
  end
end
