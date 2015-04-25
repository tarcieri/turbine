require "concurrent"

module Turbine
  # Multithreaded message processor
  class Processor
    # How long to sleep when busy waiting for the queue to empty
    BUSY_WAIT_INTERVAL = 0.0001

    def initialize(*args)
      @pool = Concurrent::ThreadPoolExecutor.new(*args)
    end

    def process(consumer, &block)
      fail ArgumentError, "no block given" unless block
      processor_method = method(:process_message)

      while (batch = consumer.fetch)
        for index in 0...batch.size
          begin
            @pool.post(batch, index, block, &processor_method)
          rescue Concurrent::RejectedExecutionError
            busy_wait
            retry
          end
        end
      end
    end

    def drain(timeout = nil)
      @pool.shutdown
      @pool.wait_for_termination(timeout)
    end

    private

    def process_message(batch, index, block)
      begin
        block.call batch[index]
      rescue => ex
        # TODO: handle exceptions or something!
        puts "#{ex.class} #{ex}\n#{ex.backtrace.join("\n")}"
      end

      batch.complete(index)
    end

    def busy_wait
      # We exceeded the pool's queue, so busy-wait and retry
      # TODO: more intelligent busy-waiting strategy
      sleep BUSY_WAIT_INTERVAL
    end
  end
end
