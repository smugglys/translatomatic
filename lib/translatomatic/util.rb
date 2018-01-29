module Translatomatic
  # Utility functions, used internally
  module Util
    # @!visibility private
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    private

    # @!visibility private
    module CommonMethods
      private

      def t(key, options = {})
        Translatomatic::I18n.t(key, options)
      end
    end

    include CommonMethods

    # @!visibility private
    module ClassMethods
      include CommonMethods
    end

    def log
      Translatomatic.config.logger
    end

    def locale(tag)
      Translatomatic::Locale.parse(tag)
    end

    def string(value, locale, options = {})
      string = Translatomatic::String.new(value, locale)
      string.context = options[:context]
      string
    end

    def hashify(list, key_mapping = proc { |i| i.to_s })
      hash = {}
      list.each do |i|
        key = key_mapping.call(i)
        hash[key] = i
      end
      hash
    end
  end
end
