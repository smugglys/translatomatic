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
        error_from_response(@response) || default_error
      end

      private

      def default_error
        "error #{@response.code}"
      end

      def error_from_response(response)
        if response.content_type == 'text/html'
          error_from_html(response.body)
        elsif response.body.present?
          response.body
        end
      end

      def error_from_html(body)
        doc = Nokogiri::HTML(body)
        texts = doc.search('//text()')
        msg = texts.find { |i| error_from_string(i.content) }
        msg ? error_from_string(msg.content) : nil
      end

      def error_from_string(string)
        match = string.match(/(?:Message|Error):\s*(.*)/i)
        match ? match[1] : nil
      end
    end
  end
end
