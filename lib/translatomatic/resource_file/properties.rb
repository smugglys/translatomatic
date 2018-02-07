require 'treetop'

module Translatomatic
  module ResourceFile
    # Properties resource file
    # @see https://docs.oracle.com/javase/tutorial/essential/environment/properties.html
    class Properties < Base
      include KeyValueSupport

      # (see Base.extensions)
      def self.extensions
        %w[properties]
      end

      # (see Base.supports_variable_interpolation?)
      def self.supports_variable_interpolation?
        true
      end

      # (see Base.preferred_locale_separator)
      def self.preferred_locale_separator
        '_'
      end

      # (see Base#create_variable)
      def create_variable(name)
        "{#{name}}"
      end

      # (see Base#variable_regex)
      def variable_regex
        /\{.*?\}/
      end

      private

      Treetop.load(File.join(__dir__, 'properties.treetop'))
      # @private
      class Parser < PropertiesParser; end

      def parse_doc(content)
        Parser.new.parse(content)
      end

      def render_element(element)
        if element.is_a? Comment
          return '' if element.text.nil?
          comments = element.text.split(/[\r\n]+/)
          comments.collect do |comment|
            format("%<type>c %<comment>s\n",
                   type: element.type, comment: comment.strip)
          end.join
        elsif element.is_a? Definition
          key = element.key
          value = element.value
          format(%(%<key>s = %<value>s\n),
                 key: escape(key), value: escape(value))
        end
      end
    end
  end
end
