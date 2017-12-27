module Translatomatic::ResourceFile
  class XML < Base

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{xml}
    end

    # (see Translatomatic::ResourceFile::Base#initialize)
    def initialize(path, locale = nil)
      super(path, locale)
      @valid = true
      @properties = @path.exist? ? read(@path) : {}
    end

    # (see Translatomatic::ResourceFile::Base#set)
    def set(key, value)
      super(key, value)
      @nodemap[key].content = value if @nodemap.include?(key)
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      if @doc
        add_created_by unless options[:no_created_by]
        target.write(@doc.to_xml)
      end
    end

    private

    def add_created_by
      @created_by ||= @doc.root.add_previous_sibling(comment(created_by))
    end

    def comment(text)
      @doc.create_comment(text)
    end

    # initialize nodemap from nokogiri document
    # returns property hash
    def init_nodemap(doc)
      # map of key1 => node, key2 => node, ...
      @nodemap = create_nodemap(doc)
      # map of key => node content
      @nodemap.transform_values { |v| v.content }
    end

    # parse key = value property file
    def read(path)
      begin
        # parse xml with nokogiri
        @doc = read_doc(path)
        init_nodemap(@doc)
      rescue Exception
        @valid = false
        {}
      end
    end

    def read_doc(path)
      Nokogiri::XML(path.open) do |config|
        config.noblanks
      end
    end

    def create_nodemap(doc)
      result = {}
      text_nodes = doc.search(text_nodes_xpath)
      idx = 1
      text_nodes.each do |node|
        next if whitespace?(node.content)
        result["key#{idx}"] = node
        idx += 1
      end
      result
    end

    def text_nodes_xpath
      '//text()'
    end

    def whitespace?(text)
      text == nil || text.strip.length == 0
    end
  end # class
end   # module
