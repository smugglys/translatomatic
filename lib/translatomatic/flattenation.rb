module Translatomatic
  # Methods to flatten data
  module Flattenation
    private

    # flatten hash or array of hashes to a hash of key => value pairs
    def flatten(data)
      result = {}

      if data.is_a?(Hash)
        data.each do |key, value|
          flatten_add(result, key, value)
        end
      elsif data.is_a?(Array)
        data.each_with_index do |value, i|
          key = 'key' + i.to_s
          flatten_add(result, key, value)
        end
      end

      result
    end

    def flatten_add(result, key, value)
      if needs_flatten?(value)
        children = flatten(value)
        children.each do |ck, cv|
          result[key + '.' + ck] = cv
        end
      else
        result[key] = value
      end
    end

    def needs_flatten?(value)
      value.is_a?(Array) || value.is_a?(Hash)
    end

  end
end
