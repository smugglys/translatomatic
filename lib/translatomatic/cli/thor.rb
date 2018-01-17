module Translatomatic
  module CLI
    module ThorPatch
      # disable --no booleans
      module NoNo
        def usage(padding = 0)
          sample = if banner && !banner.to_s.empty?
            "#{switch_name}=#{banner}".dup
          else
            switch_name
          end

          sample = "[#{sample}]".dup unless required?

          if aliases.empty?
            (" " * padding) << sample
          else
            "#{aliases.join(', ')}, #{sample}"
          end
        end
      end
    end
  end
end
