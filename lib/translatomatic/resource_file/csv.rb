require 'csv'

module Translatomatic::ResourceFile
  # CSV resource file
  class CSV < Base
    # (see Translatomatic::ResourceFile::Base.extensions)
    def self.extensions
      %w[csv]
    end

    # (see Translatomatic::ResourceFile::Base#save)
    def save(target = path, _options = {})
      ::CSV.open(target, 'wb') do |csv|
        @properties.each do |key, value|
          csv << [key, value]
        end
      end
    end

    private

    def init
      @rows = []
    end

    def load
      contents = read_contents(@path)
      @rows = ::CSV.parse(contents)
      @properties = {}
      @rows.each do |key, value|
        @properties[key] = value
      end
    end
  end
end
