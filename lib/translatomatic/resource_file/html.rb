module Translatomatic
  module ResourceFile
    # HTML resource file
    class HTML < XML
      # (see Base.extensions)
      def self.extensions
        %w[html htm shtml]
      end

      # (see Base#save)
      def save(target = path, options = {})
        return unless @doc
        add_created_by unless options[:no_created_by]
        target.write(@doc.to_html)
      end

      private

      def read_doc
        doc = Nokogiri::HTML(@path.open, &:noblanks)
        parse_error(doc.errors[0]) if doc.errors.present?
        doc
      end

      def empty_doc
        Nokogiri::HTML('<html><body></body></html>')
      end

      def text_nodes_xpath
        '//*[not(self::code)]/text()|//comment()'
      end
    end
  end
end
