module Translatomatic
  # @!visibility private
  module DefineOptions
    # @!visibility private
    module ClassMethods
      attr_reader :options

      private

      def define_option(name, attributes = {})
        @options ||= []
        @options << Translatomatic::Option.new(attributes.merge(name: name))
      end
    end

    # @!visibility private
    def self.included(klass)
      klass.extend(ClassMethods)
    end
  end
end
