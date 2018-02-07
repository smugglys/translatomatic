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
          process_node(node)
        end
      end

      def process_node(node)
        if node.comment?
          @metadata.parse_comment(node.content)
        elsif node.type == Nokogiri::XML::Node::ATTRIBUTE_NODE # data name=""
          @key = node.content
        elsif node.text?
          process_text_node(node)
        end
      end

      def process_text_node(node)
        parent = node.parent
        if parent.name == 'value' # <value>content</value>
          found_value(node)
        elsif parent.name == 'comment'
          @metadata.parse_comment(node.content)
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
        text_node = Nokogiri::XML::Text.new(value.to_s, @doc)
        value_node.add_child(text_node)
        data_node.add_child(value_node)

        @doc.root.add_child(data_node)

        @nodemap[key] = text_node
        @properties[key] = value
      end
    end
  end
end
