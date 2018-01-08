module Translatomatic::ResourceFile
  # HTML resource file
  class HTML < XML

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{html htm shtml}
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      if @doc
        add_created_by unless options[:no_created_by]
        target.write(@doc.to_html)
      end
    end

    private

    def read_doc
      doc = Nokogiri::HTML(@path.open) do |config|
        config.noblanks
      end
      parse_error(doc.errors[0]) if doc.errors.present?
      doc
    end

    def empty_doc
      Nokogiri::HTML("<html><body></body></html>")
    end

    def text_nodes_xpath
      '//*[not(self::code)]/text()'
    end

  end
end
