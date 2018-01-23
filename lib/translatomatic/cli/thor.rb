module Translatomatic
  module CLI
    # @private
    module ThorPatch
      # disable --no booleans
      # @private
      module NoNo
        def usage(padding = 0)
          sample = usage_banner
          sample = "[#{sample}]".dup unless required?

          if aliases.empty?
            (' ' * padding) << sample
          else
            "#{aliases.join(', ')}, #{sample}"
          end
        end

        def usage_banner
          if banner && !banner.to_s.empty?
            "#{switch_name}=#{banner}".dup
          else
            switch_name
          end
        end
      end
    end
  end
end
