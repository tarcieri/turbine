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
      loop do
        batch = consumer.fetch
        break unless batch

        batch.size.times do |index|
          begin
            @pool.post { process_message(batch, index, &block) }
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

    def process_message(batch, index, &block)
      begin
        block.call(batch[index])
      rescue => ex
        puts "#{ex.class} #{ex}\n#{ex.backtrace.join("\n")}"
        # TODO: handle exceptions or something!
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
