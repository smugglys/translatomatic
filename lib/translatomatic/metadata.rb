module Translatomatic
  # Parses tm.context comments in resource files
  class Metadata
    attr_reader :context

    def initialize
      reset
    end

    def get_context(key)
      @context[key]
    end

    def reset
      @context = {}
      @current_context = nil
    end

    # assign current metadata to the given key
    def assign_key(key, options = {})
      if @current_context.present?
        @context[key] = @current_context
        @current_context = nil unless options[:keep_context]
      end
    end

    def clear_context
      @current_context = nil
    end

    def add_context(context)
      return unless context.present?
      @current_context ||= []
      @current_context << context.strip
    end

    # Parse comment text for metadata
    # @return context [Array] parsed context data
    def parse_comment(comment)
      return nil if comment.blank?
      contexts = comment.scan(/tm\.context:\s*(.*)/)
      result = []
      contexts.each do |i|
        add_context(i[0])
        result << i[0]
      end
      result
    end
  end
end
