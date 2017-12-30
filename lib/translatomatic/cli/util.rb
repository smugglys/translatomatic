module Translatomatic::CLI
  class Util

    def self.options(klass, items)
      if items.respond_to?(:options)
        options(klass, items.options)
      elsif items.kind_of?(Array)
        items.each do |item|
          if item.kind_of?(Translatomatic::Option)
            klass.method_option item.name, item.to_hash
          elsif item.respond_to?(:options)
            options(klass, item.options)
          end
        end
      end
    end
  end
end
