module Translatomatic::ResourceFile
  class XML < Base

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

    # (see Translatomatic::ResourceFile::Base#save(target))
    def save(target = path)
      target.write(@doc.to_xml) if @doc
    end

    private

    # initialize nodemap from nokogiri document
    # returns property hash
    def init_nodemap(doc)
      # map of key1 => node, key2 => node, ...
      @nodemap = flatten_xml(doc)
      # map of key => node content
      @nodemap.transform_values { |v| v.content }
    end

    # parse key = value property file
    def read(path)
      begin
        # parse xml with nokogiri
        @doc = Nokogiri::XML(path.open) do |config|
          config.noblanks
        end
        init_nodemap(@doc)
      rescue Exception
        @valid = false
        {}
      end
    end

    def flatten_xml(doc)
      result = {}
      text_nodes = doc.search(text_nodes_xpath)
      text_nodes.each_with_index do |node, i|
        result["key#{i + 1}"] = node
      end
      result
    end

    def text_nodes_xpath
      '//text()'
    end
  end # class
end   # module
