require 'treetop'

module Translatomatic
  module ResourceFile
    # XCode strings resource file
    # @see https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html
    class XCodeStrings < Base
      include KeyValueSupport

      # (see Base.extensions)
      def self.extensions
        %w[strings]
      end

      private

      Treetop.load(File.join(__dir__, 'xcode_strings.treetop'))
      # @private
      class Parser < XCodeStringsParser; end

      def parse_doc(content)
        Parser.new.parse(content)
      end

      def definition_to_s(_definition)
        format(%("%<key>s" = "%<value>s";\n\n), key: escape(key),
                                                value: escape(value))
      end

      def comment_to_s
        comment = text && text.start_with?(' ') ? text : " #{text} "
        "/*#{comment}*/\n"
      end

      def render_element(element)
        if element.is_a? Comment
          text = element.text
          comment = text && text.start_with?(' ') ? text : " #{text} "
          %(/*#{comment}*/\n)
        elsif element.is_a? Definition
          key = element.key
          value = element.value
          format(%("%<key>s" = "%<value>s";\n\n), key: escape(key),
                                                  value: escape(value))
        end
      end
    end
  end
end
