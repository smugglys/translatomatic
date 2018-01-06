module Translatomatic::ResourceFile
  # Property list resource file
  # @see https://en.wikipedia.org/wiki/Property_list
  class Plist < XML
    # property list types:
    # array, dict, string, data, date, integer, real, boolean
    # boolean is <true /> or <false />

    include Translatomatic::ResourceFile::XCodeStringsLocalePath

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{plist}
    end

    # (see Translatomatic::ResourceFile::Base.is_key_value?)
    def self.is_key_value?
      true
    end

    private

    def init_nodemap
      result = Parser.new.parse(@doc)
      #puts "parser result:"
      #p result
      @flattened_data = flatten(result)
      @nodemap = @flattened_data.transform_values { |i| i.node }
      #puts "nodemap:"
      #p @nodemap
    end

    def init_properties
      @properties = @flattened_data.transform_values { |i| i.content }
    end

    def create_node(key, value)
      # add properties to first dict found
      dict = @doc.xpath("//dict")
      # TODO: not sure sure what to do if dict is missing
      raise "missing top level dictionary" unless dict.present?
      dict = dict[0]

      # add xml: <data name="key"><value>value</value></data>
      key_node = Nokogiri::XML::Node.new("key", @doc)
      key_node.content = key
      value_node = Nokogiri::XML::Node.new("string", @doc)
      value_node.content = value
      dict.add_child(key_node)
      dict.add_child(value_node)

      @nodemap[key] = value_node
      @properties[key] = value
    end

    def empty_doc
      Nokogiri::XML(EMPTY_DOC)
    end

    EMPTY_DOC=<<EOM
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
          'integer' => Proc.new { |node| node.content.to_i },
          'real'    => Proc.new { |node| node.content.to_f },
          'string'  => Proc.new { |node| node.content.to_s },
          # DateTime.parse(node.content)
          'date'    => Proc.new { |node| node.content.to_s },
          'true'    => Proc.new { |node| true },
          'false'   => Proc.new { |node| false },
          'dict'    => Proc.new { |node| parse_dict(node) },
          'array'   => Proc.new { |node| parse_array(node) },
          'data'    => Proc.new { |node| node.content.to_s }
        }.merge(options[:converters] || {})

        @dict_class = options[:dict_class] || Hash
        plist = xml.root
        plist = plist.children.first if plist.name == "plist"
        result = parse_value_node(next_valid_sibling plist)
        plist_node_value(result)
      end

      def parse_value_node(value_node)
        value = @converters[value_node.name].call(value_node)
        PlistNode.new(value_node, value)
      end

      def valid_type?(type)
        @converters.has_key? type
      end

      def valid_node?(node)
        valid_type?(node.name) or node.name == "key"
      end

      def parse_dict(node)
        node.xpath('./key').inject(@dict_class.new) do |result, key_node|
          plist_node = parse_value_node(next_valid_sibling key_node)
          value = plist_node_value(plist_node)
          result[key_node.content] = value
          result
        end
      end

      # if the PlistNode value is an array or hash, use that directly
      # instead of the PlistNode.
      def plist_node_value(plist_node)
        content = plist_node.content
        if content.kind_of?(Array) || content.kind_of?(Hash)
          content
        else
          plist_node
        end
      end

      def parse_array(node)
        node.children.inject([]) do |result, child|
          if valid_node?(child)
            plist_node = parse_value_node(child)
            result << plist_node_value(plist_node)
          end
          result
        end
      end

      def next_valid_sibling(node)
        until node.nil? or valid_type? node.name
          node = node.next_sibling
        end
        node
      end

    end

  end # class
end   # module
