require 'kramdown'
require 'reverse_markdown'

module Translatomatic::ResourceFile
  class Markdown < HTML

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{md}
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      if @doc
        begin
          add_created_by unless options[:no_created_by]
          html = @doc.to_html
          # convert html back to markdown
          markdown = ReverseMarkdown.convert(html, unknown_tags: :bypass)
          target.write(markdown.chomp)
        rescue Exception => e
          puts "error: #{e.message}"
        end
      end
    end

    private

    def add_created_by
      @created_by ||= begin
        body = @doc.at('body')
        body.add_child("<p><i>#{created_by}</i></p>")
      end
    end

    def read(path)
      begin
        # read markdown and convert to html
        markdown = path.read
        html = Kramdown::Document.new(markdown).to_html
        # parse html with nokogiri
        @doc = Nokogiri::HTML(html) do |config|
          config.noblanks
        end
        init_nodemap(@doc)
      rescue Exception => e
        log.error(e.message)
        @valid = false
        {}
      end
    end

  end  # class
end    # module
