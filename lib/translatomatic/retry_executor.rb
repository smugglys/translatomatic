module Translatomatic
  # Executes code with retry on exceptions
  class RetryExecutor
    include Util

    class << self
      def run(options = {})
        new(options).run { yield }
      end
    end

    def initialize(options = {})
      @max_retries = options[:max_retries] || 3
      @retriable = options[:retriable] || [StandardError]
      @delay = options[:retry_delay]
    end

    # Attempt to run a block of code up to retries times.
    # Reraises the exception if the block fails retries times or if
    #   a non-retriable exception was raised.
    # @return [Object] the return value of the block
    def run
      fail_count = 0
      begin
        yield
      rescue StandardError => e
        log.error(e.message)
        fail_count += 1
        if fail_count < @max_retries && retriable?(e)
          sleep @delay if @delay
          retry
        end
        puts "exception #{e} not retriable"
        raise e
      end
    end

    def retriable?(exception)
      @retriable.any? { |i| exception.kind_of?(i) }
    end
  end
end
