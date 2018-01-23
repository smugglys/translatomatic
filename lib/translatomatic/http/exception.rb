module Translatomatic
  module HTTP
    # Exception used for unexpected http responses
    class Exception < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end

      # Exception string
      def to_s
        @response.to_s
      end
    end
  end
end
