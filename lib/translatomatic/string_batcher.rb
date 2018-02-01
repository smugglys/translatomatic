module Translatomatic
  # each_slice with a limit on number of strings and also an optional
  # character limit.
  class StringBatcher
    include Util

    # @param strings [Array<String>] A list of strings to return in batches
    # @param max_count [Number] The maximum number of strings to return
    # @param max_length [Number] The maximum total length of strings to return
    def initialize(strings, max_count:, max_length:)
      @strings = strings
      @max_count = max_count
      @max_length = max_length
      @batch = []
      @length = 0
    end

    # Yields lists of strings within the size constraints given to the
    # constructor.
    # @return [Array<String>] List of strings
    def each_batch
      @strings.each do |string|
        process_string(string) { |batch| yield batch }
      end
      yield_batch { |batch| yield batch } # send remaining strings
    end

    private

    def process_string(string)
      if @max_length && @length + string.length >= @max_length
        raise t('translator.string_too_long') if @batch.empty?
        yield_batch { |batch| yield batch }
      end

      # add string to batch
      @batch << string
      @length += string.length

      return if @max_count && @batch.length < @max_count
      yield_batch { |batch| yield batch }
    end

    def yield_batch
      yield @batch if @batch.present?
      @batch = []
      @length = 0
    end
  end
end