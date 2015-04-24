require "concurrent"

module Turbine
  # Multithreaded message processor
  class Processor
    def initialize(*args)
      @pool = Concurrent::ThreadPoolExecutor.new(*args)
    end

    def process(consumer, &block)
      loop do
        batch = consumer.fetch
        break unless batch

        0.upto(batch.size - 1) do |index|
          begin
            @pool.post { process_message(batch, index, &block) }
          rescue Concurrent::RejectedExecutionError
            # We exceeded the pool's queue, so busy-wait and retry
            # TODO: more intelligent busy-waiting strategy
            sleep 0.0001
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
  end
end
