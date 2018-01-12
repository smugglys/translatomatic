module Translatomatic
  # Type casting functions used by Translatomatic::Config
  module TypeCast

    def cast(value, type)
      value = value[0] if value.is_a?(Array) && !array_type?(type)

      case type
      when :boolean
        bool_value(value)
      when :string
        return value.nil? ? value : value.to_s
      when :path
        cast_path(value)
      when :array, :path_array
        array_value(value)
      else
        # no casting
        value
      end
    end

    private

    def cast_path(value)
      return nil if value.nil?
      homeify(value.to_s)
    end

    def homeify(path)
      parts = File.split(path)
      if parts[0] && parts[0] == '~'
        # replace ~ with home directory
        parts[0] = Dir.home
        path = File.join(parts)
      end
      path
    end

    def array_type?(type)
      %i[path_array array].include?(type)
    end

    def array_value(value)
      if value.nil?
        []
      else
        value = [value] unless value.is_a?(Array)
        value.collect { |i| i.split(/[, ]/) }.flatten.compact
      end
    end

    def bool_value(value)
      return true if %w[true t yes on].include?(value)
      return false if %w[false f no off].include?(value)
      value ? true : false
    end

  end
end
