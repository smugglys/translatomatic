module Translatomatic::ResourceFile
  # Windows resources file (XML)
  class RESW < XML

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{resw resx}
    end

    # (see Translatomatic::ResourceFile::Base.is_key_value?)
    def self.is_key_value?
      true
    end

    # (see Translatomatic::ResourceFile::Base#locale_path)
    def locale_path(locale)
      # e.g. strings/en-US/resources.resw
      dir = path.dirname
      dir.parent + locale.to_s + path.basename
    end

    private

    def init_nodemap
      result = {}
      key_values = @doc.search('//data/@name|//text()')
      key_values.each_slice(2) do |key, value|
        key = key.value
        value = value
        result[key] = value
      end
      @nodemap = result
    end

    def create_node(key, value)
      # add xml: <data name="key"><value>value</value></data>
      data_node = Nokogiri::XML::Node.new("data", @doc)
      data_node["name"] = key
      value_node = Nokogiri::XML::Node.new("value", @doc)
      text_node = Nokogiri::XML::Text.new(value, @doc)
      value_node.add_child(text_node)
      data_node.add_child(value_node)

      @doc.root.add_child(data_node)

      @nodemap[key] = text_node
      @properties[key] = value
    end

  end # class
end   # module
