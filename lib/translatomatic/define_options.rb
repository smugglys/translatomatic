module Translatomatic
  # @!visibility private
  module DefineOptions

    # @!visibility private
    module ClassMethods
      attr_reader :options

      private

      def define_options(*options)
        @options = options.collect { |i| Translatomatic::Option.new(i) }
      end
    end

    private

    def self.included(klass)
      klass.extend(ClassMethods)
    end
  end
end
