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

        if @subtitle_map.include?(key)
          @subtitle_map[key][:lines] = value.to_s
        else
          add_subtitle(lines: value) unless value.blank?
        end
      end

      # (see Base#save)
      def save(target = path, options = {})
        add_created_by unless options[:no_created_by] || have_created_by?
        export(target)
      end

      private

      def init
        @subtitle_map = {}
        @subtitles = []
        @keynum = 1
      end

      def load
        @metadata.reset
        subtitles = import(@path)
        subtitles.each { |i| add_subtitle(i) }
        init_properties
      end

      def process_metadata(key, subtitle)
        lines = subtitle[:lines] || ''
        context = @metadata.parse_comment(lines)
        @metadata.assign_key(key) unless context.present?
      end

      def add_created_by
        # TODO
      end

      def add_subtitle(subtitle = {})
        key = "key#{@keynum}"
        subtitle[:id] ||= @keynum
        subtitle[:start] ||= @keynum * 10
        subtitle[:end] ||= @keynum * 10 + 5
        @keynum += 1
        @subtitle_map[key] = subtitle
        @subtitles << subtitle
      end

      # Find the first gap in subtitles with a minimum length in seconds.
      # @return [Array] [start, end] Start and end times of the gap
      def find_gap(min_length)
        last = 0
        @subtitles.each do |subtitle|
          return [last, subtitle.start] if subtitle.start - last >= min_length
          last = subtitle.end
        end
        [last, -1]
      end

      def init_properties
        @properties = @subtitle_map.transform_values { |i| i[:lines] }
      end

      def import(path)
        contents = read_contents(path)
        return [] if contents.blank?
        import_export_class(path).import(contents)
      end

      def export(target, _options = {})
        content = import_export_class(target).export(@subtitles) || ''
        content = content.gsub(/[\r\n]+\Z/, '') + "\n"
        target.write(content)
      end

      def import_export_class(path)
        class_name = path.extname.sub(/^\./, '').upcase
        Titlekit.const_get(class_name)
      end
    end
  end
end
