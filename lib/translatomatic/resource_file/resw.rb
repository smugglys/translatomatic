module Translatomatic
  module ResourceFile
    # Windows resources file (XML)
    class RESW < XML
      # (see Base.extensions)
      def self.extensions
        %w[resw resx]
      end

      # (see Base.key_value?)
      def self.key_value?
        true
      end

      private

      def init_nodemap
        @nodemap = {}
        nodes = @doc.search('//data/@name|//text()|//comment()')
        nodes.each do |node|
          parent = node.parent
          if node.comment?
            @metadata.parse_comment(node.content)
          elsif node.type == Nokogiri::XML::Node::ATTRIBUTE_NODE # data name=""
            @key = node.content
          elsif node.text? && parent.name == 'value' # <value>content</value>
            found_value(node)
          elsif node.text? && parent.name == 'comment'
            @metadata.parse_comment(node.content)
          end
        end
      end

      def found_value(value)
        @nodemap[@key] = value if @key
        @metadata.assign_key(@key)
        @key = nil
      end

      def create_node(key, value)
        # add xml: <data name="key"><value>value</value></data>
        data_node = Nokogiri::XML::Node.new('data', @doc)
        data_node['name'] = key
        value_node = Nokogiri::XML::Node.new('value', @doc)
        text_node = Nokogiri::XML::Text.new(value, @doc)
        value_node.add_child(text_node)
        data_node.add_child(value_node)

        @doc.root.add_child(data_node)

        @nodemap[key] = text_node
        @properties[key] = value
      end
    end
  end
end
