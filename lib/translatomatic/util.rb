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
      private

      include CommonMethods
    end

    def log
      Translatomatic.config.logger
    end

    def locale(tag)
      Translatomatic::Locale.parse(tag)
    end

    def string(value, locale)
      Translatomatic::String.new(value, locale)
    end

    def hashify(list)
      hash = {}
      list.each { |i| hash[i.to_s] = i }
      hash
    end
  end
end
