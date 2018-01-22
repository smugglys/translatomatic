module Translatomatic
  module ResourceFile
    # XML resource file
    class XML < Base
      # (see Base.extensions)
      def self.extensions
        %w[xml]
      end

      # (see Base#set)
      def set(key, value)
        super(key, value)
        if @nodemap.include?(key)
          @nodemap[key].content = value
        else
          create_node(key, value)
        end
      end

      # (see Base#save)
      def save(target = path, options = {})
        return unless @doc
        add_created_by unless options[:no_created_by] || have_created_by?
        target.write(@doc.to_xml(indent: 2))
      end

      private

      TM_NS = 'http://www.smugglys.com/2018/translatomatic'.freeze

      def init
        @nodemap = {}
        @doc = empty_doc
      end

      def load
        # parse xml with nokogiri
        @metadata.reset
        @doc = read_doc
        init_nodemap
        init_properties
      end

      def comment(text)
        @doc.create_comment(text)
      end

      def add_created_by
        @created_by ||= @doc.root.add_previous_sibling(comment(created_by))
      end

      def init_properties
        @properties = @nodemap.transform_values { |i| i ? i.content : nil }
      end

      # initialize nodemap and properties hash from nokogiri document
      def init_nodemap
        # map of key1 => node, key2 => node, ...
        @keynum = 1
        text_nodes = @doc.search(text_nodes_xpath, tm: TM_NS)
        text_nodes.each { |node| add_node(node) }
      end

      def read_doc
        doc = Nokogiri::XML(@path.open, &:noblanks)
        parsing_error(doc.errors[0]) if doc.errors.present?
        doc
      end

      def create_node(key, value)
        # separate nodes by whitespace
        text_node = Nokogiri::XML::Text.new("\n", @doc)
        @doc.root.add_child(text_node)

        # create the key/value node
        node = Nokogiri::XML::Node.new(key, @doc)
        node.content = value
        @doc.root.add_child(node)

        @nodemap[key] = node
        @properties[key] = node.content
      end

      def add_node(node)
        return if whitespace?(node.content)
        if node.comment?
          @metadata.parse_comment(node.content)
        elsif context_attribute?(node)
          @metadata.add_context(node.content)
        else
          key = "key#{@keynum}"
          @nodemap[key] = node
          @keynum += 1
          @metadata.assign_key(key)
        end
      end

      def context_attribute?(node)
        node.name == 'context' && node.namespace &&
          node.namespace.href == TM_NS
      end

      def empty_doc
        Nokogiri::XML('<root />')
      end

      def text_nodes_xpath
        '//text()|//comment()|//@tm:context'
      end

      def whitespace?(text)
        text.nil? || text.strip.empty?
      end
    end
  end
end
