module Translatomatic
  module ResourceFile
    # Subtitle resource file.
    # requires 'titlekit' gem
    class Subtitle < Base
      # (see Base.extensions)
      def self.extensions
        %w[srt ass ssa]
      end

      # (see Base.enabled?)
      def self.enabled?
        @enabled ||= begin
          require 'titlekit'
          true
        rescue LoadError
          false
        end
      end

      # (see Base#set)
      def set(key, value)
        super(key, value)
        @subtitle_map[key][:lines] = value if @subtitle_map.include?(key)
      end

      # (see Base#save)
      def save(target = path, options = {})
        add_created_by unless options[:no_created_by] || added_created_by?
        export(target)
      end

      private

      def init
        @subtitle_map = {}
        @subtitles = []
      end

      def load
        @subtitles = import(@path)
        init_subtitle_map
        init_properties
      end

      def init_subtitle_map
        # map of key1 => subtitle, key2 => subtitle, ...
        @keynum = 1
        @subtitles.each_with_index do |subtitle, _i|
          key = "key#{@keynum}"
          @keynum += 1
          @subtitle_map[key] = subtitle
        end
      end

      def add_created_by
        # TODO
      end

      def added_created_by?
        false # TODO
      end

      def init_properties
        @properties = @subtitle_map.transform_values { |i| i[:lines] }
      end

      def import(path)
        import_export_class(path).import(read_contents(path))
      end

      def export(target, _options = {})
        content = import_export_class(target).export(@subtitles) || ''
        target.write(content.chomp)
      end

      def import_export_class(path)
        class_name = path.extname.sub(/^\./, '').upcase
        Titlekit.const_get(class_name)
      end
    end
  end
end
