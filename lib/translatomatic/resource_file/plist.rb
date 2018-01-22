module Translatomatic
  module ResourceFile
    # Property list resource file
    # @see https://en.wikipedia.org/wiki/Property_list
    class Plist < XML
      # property list types:
      # array, dict, string, data, date, integer, real, boolean
      # boolean is <true /> or <false />

      # (see Base.extensions)
      def self.extensions
        %w[plist]
      end

      # (see Base.key_value?)
      def self.key_value?
        true
      end

      private

      def init_nodemap
        result = Parser.new.parse(@doc)
        # puts "parser result:"
        # p result
        @flattened_data = flatten(result)
        @nodemap = @flattened_data.transform_values(&:node)
        # puts "nodemap:"
        # p @nodemap
      end

      def init_properties
        @properties = @flattened_data.transform_values(&:content)
      end

      def create_node(key, value)
        # add properties to first dict found
        dict = @doc.xpath('//dict')
        # TODO: not sure sure what to do if dict is missing
        raise 'missing top level dictionary' unless dict.present?
        dict = dict[0]

        # add xml: <data name="key"><value>value</value></data>
        key_node = Nokogiri::XML::Node.new('key', @doc)
        key_node.content = key
        value_node = Nokogiri::XML::Node.new('string', @doc)
        value_node.content = value
        dict.add_child(key_node)
        dict.add_child(value_node)

        @nodemap[key] = value_node
        @properties[key] = value
      end

      def empty_doc
        Nokogiri::XML(EMPTY_DOC)
      end

      EMPTY_DOC = <<EOM.strip_heredoc.freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  </dict>
  </plist>
EOM

      PlistNode = Struct.new(:node, :content) do
        def inspect
          "PlistNode:#{content}"
        end
      end

      # Adapted from nokogiri-plist parser
      # @see https://github.com/caseyhoward/nokogiri-plist
      class Parser
        def parse(xml, options = {})
          @converters = {
            'integer' => proc { |node| node.content.to_i },
            'real'    => proc { |node| node.content.to_f },
            'string'  => proc { |node| node.content.to_s },
            # DateTime.parse(node.content)
            'date'    => proc { |node| node.content.to_s },
            'true'    => proc { |_node| true },
            'false'   => proc { |_node| false },
            'dict'    => proc { |node| parse_dict(node) },
            'array'   => proc { |node| parse_array(node) },
            'data'    => proc { |node| node.content.to_s }
          }.merge(options[:converters] || {})

          @dict_class = options[:dict_class] || Hash
          plist = xml.root
          plist = plist.children.first if plist.name == 'plist'
          result = parse_value_node(next_valid_sibling(plist))
          plist_node_value(result)
        end

        def parse_value_node(value_node)
          value = @converters[value_node.name].call(value_node)
          PlistNode.new(value_node, value)
        end

        def valid_type?(type)
          @converters.key? type
        end

        def valid_node?(node)
          valid_type?(node.name) || node.name == 'key'
        end

        def parse_dict(node)
          node.xpath('./key').each_with_object(@dict_class.new) do |k, v|
            plist_node = parse_value_node(next_valid_sibling(k))
            value = plist_node_value(plist_node)
            v[k.content] = value
          end
        end

        # if the PlistNode value is an array or hash, use that directly
        # instead of the PlistNode.
        def plist_node_value(plist_node)
          content = plist_node.content
          if content.is_a?(Array) || content.is_a?(Hash)
            content
          else
            plist_node
          end
        end

        def parse_array(node)
          node.children.each_with_object([]) do |child, result|
            if valid_node?(child)
              plist_node = parse_value_node(child)
              result << plist_node_value(plist_node)
            end
          end
        end

        def next_valid_sibling(node)
          node = node.next_sibling until node.nil? || valid_type?(node.name)
          node
        end
      end
    end
  end
end
