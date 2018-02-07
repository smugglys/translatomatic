require 'yaml'

module Translatomatic
  module ResourceFile
    # YAML resource file
    # @see http://www.yaml.org/
    class YAML < Base
      # (see Base.extensions)
      def self.extensions
        %w[yml yaml]
      end

      # (see Base.key_value?)
      def self.key_value?
        true
      end

      # (see Base.supports_variable_interpolation?)
      def self.supports_variable_interpolation?
        true
      end

      # (see Base#set)
      def set(key, value)
        super(key, value)

        hash = @data
        path = key.to_s.split(/\./)
        last_key = path.pop
        path.each { |i| hash = (hash[i] ||= {}) }
        hash[last_key] = value
      end

      # (see Base#save)
      def save(target = path, options = {})
        return unless @data
        data = @data
        data = data.transform_keys { locale.language } if ruby_i18n?
        out = data.to_yaml
        out.sub!(/^---\n/m, '')
        out = comment(created_by) + "\n" + out unless options[:no_created_by]
        target.write(out)
      end

      # (see Base#create_variable)
      def create_variable(name)
        "%{#{name}}"
      end

      # (see Base#variable_regex)
      def variable_regex
        /\%\s*\{.*?\}/
      end

      private

      def init
        # yaml data
        @data = {}
      end

      def load
        @data = ::YAML.load_file(path.to_s) || {}
        @properties = flatten(@data)
      end

      # true if this resource file looks like a ruby i18n data file.
      def ruby_i18n?
        if @data && @data.length == 1
          lang = @data.keys[0]
          Translatomatic::Locale.new(lang).valid?
        end
      end

      def comment(text)
        "# #{text}\n"
      end
    end
  end
end
