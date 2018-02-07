module Translatomatic
  # Parses tm.context comments in resource files
  class Metadata
    attr_reader :context

    def initialize
      reset
    end

    # Find associated context(s) for a property.
    # Contexts are defined using tm.context comments in resource files.
    # @return [Array<String>] Context for the given key
    def get_context(key)
      @context[key]
    end

    # Clear all metadata
    def reset
      @context = {}
      @current_context = nil
    end

    # Assign current metadata to the given key
    # @param key [String] name of the key
    def assign_key(key, options = {})
      if @current_context.present?
        @context[key] = @current_context
        @current_context = nil unless options[:keep_context]
      end
    end

    # Clear the current context
    def clear_context
      @current_context = nil
    end

    # Add to the current context
    # @param context [String] A context string
    def add_context(context)
      return unless context.present?
      @current_context ||= []
      @current_context << context.strip
    end

    # Parse comment text and extract metadata
    # @return [Array] parsed context data
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
