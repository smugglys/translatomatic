require 'csv'

module Translatomatic
  module ResourceFile
    # CSV resource file
    class CSV < Base
      # (see Base.extensions)
      def self.extensions
        %w[csv]
      end

      # (see Base#save)
      def save(target = path, options = {})
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
end
