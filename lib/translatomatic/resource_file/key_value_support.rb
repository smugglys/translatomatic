module Translatomatic
  module ResourceFile
    # @private
    module KeyValueSupport
      # (see Base.key_value?)
      def self.key_value?
        true
      end

      # (see Base#set)
      def set(key, value)
        super(key, value)
        if @map.include?(key)
          @map[key].value = value
        else
          element = Definition.new(key, value)
          @elements << element
          @map[key] = element
          @properties[key] = value
        end
      end

      # (see Base#save)
      def save(target = path, options = {})
        add_created_by unless options[:no_created_by] || have_created_by?
        content = @elements.collect { |i| render_element(i) }.join
        content = content.gsub(/[\r\n]+\Z/, '') + "\n"
        target.write(content)
      end

      private

      def init
        @elements = []  # key/values or comment elements
        @map = {}       # map key to elements
      end

      def load
        @metadata.reset
        @doc = read_doc
        @elements = init_elements
        @properties = {}
        @elements.each do |element|
          if element.is_a?(Comment)
            @metadata.parse_comment(element.text)
          elsif element.is_a?(Definition)
            @metadata.assign_key(element.key)
            @properties[element.key] = element.value
            @map[element.key] = element
          end
        end
      end

      # parse document to a list of elements
      def read_doc
        content = read_contents(@path)
        document = parse_doc(content)
        raise t('file.invalid') unless document
        document
      end

      def parse_doc(_content)
        raise 'parse_doc must be implemented by subclass'
      end

      def render_element(_element)
        raise 'render_element must be implemented by subclass'
      end

      def init_elements
        # convert to a list of elements
        @doc.content.collect do |item|
          case item[0]
          when :comment
            content_to_comment(item)
          when :definition
            content_to_definition(item)
          end
        end
      end

      def content_to_definition(item)
        key = unescape(item[1])
        value = unescape(item[2])
        # remove line continuations
        value = value.gsub(/\\\n\s*/, '')
        Definition.new(key, value)
      end

      def content_to_comment(item)
        text = unescape(item[1])
        Comment.new(text, item[2])
      end

      def add_created_by
        @created_by ||= begin
          created_by = Comment.new(created_by)
          @elements.unshift(created_by)
          created_by
        end
      end

      def escape(value)
        Translatomatic::StringEscaping.escape(value)
      end

      def unescape(value)
        Translatomatic::StringEscaping.unescape_all(value)
      end

      # @private
      Definition = Struct.new(:key, :value)
      # @private
      Comment = Struct.new(:text, :type)
    end
  end
end
