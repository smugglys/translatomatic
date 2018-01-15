module Translatomatic::ResourceFile
  # Text resource file
  class Text < Base
    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w[txt text]
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, options = {})
      values = @properties.values.collect { |i| i.strip + "\n" }
      target.write(values.join)
    end

    private

    def load
      text = read_contents(@path)
      @properties = { 'text' => text }
    end
  end
end
