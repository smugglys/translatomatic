require 'kramdown'
require 'reverse_markdown'

module Translatomatic::ResourceFile
  # Markdown resource file
  class Markdown < HTML

    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w{md}
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      if @doc
        add_created_by unless options[:no_created_by]
        html = @doc.to_html
        # convert html back to markdown
        markdown = ReverseMarkdown.convert(html, unknown_tags: :bypass)
        target.write(markdown.chomp)
      end
    end

    private

    def add_created_by
      @created_by ||= begin
        body = @doc.at('body')
        body.add_child("<p><i>#{created_by}</i></p>")
      end
    end

    def read_doc
      # read markdown and convert to html
      markdown = read_contents(@path)
      if markdown.blank?
        empty_doc
      else
        html = Kramdown::Document.new(markdown).to_html
        # parse html with nokogiri
        doc = Nokogiri::HTML(html) do |config|
          config.noblanks
        end
        parse_error(doc.errors[0]) if doc.errors.present?
        doc
      end
    end

  end  # class
end    # module
