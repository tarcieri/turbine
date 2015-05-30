module Turbine
  # Multithreaded message processor
  class Processor
    # How long to sleep when busy waiting for the queue to empty
    BUSY_WAIT_INTERVAL = 0.0001

    def initialize(*args)
      @running = Concurrent::AtomicBoolean.new
      @pool = Concurrent::ThreadPoolExecutor.new(*args)
      @completed_count = Concurrent::AtomicFixnum.new
      @pending = []
      @error_handler = proc do |ex|
        STDERR.puts "*** Error processing message: #{ex.class} #{ex}\n#{ex.backtrace.join("\n")}"
      end
    end

    def process(consumer, &block)
      fail ArgumentError, "no block given" unless block
      processor_method = method(:process_batch)

      @running.value = true
      while @running.value && (batch = consumer.fetch)
        enqueue_batch(batch)

        begin
          @pool.post(batch, block, &processor_method)
        rescue Concurrent::RejectedExecutionError
          busy_wait(consumer)
          retry
        end

        commit_completions(consumer)
      end
    end

    def stop
      @running.value = false
    end

    def drain(timeout = nil)
      stop
      @pool.shutdown
      @pool.wait_for_termination(timeout)
    end

    def completed_count
      @completed_count.value
    end

    def running?
      @running.value
    end

    def error_handler(&block)
      @error_handler = block
    end

    private

    def enqueue_batch(batch)
      partition = @pending[batch.partition] ||= []
      partition << batch
    end

    def commit_completions(consumer)
      for partition in @pending
        next unless partition

        last_completed_batch = nil
        while (batch = partition.first) && batch.completed?
          last_completed_batch = partition.shift
        end

        consumer.commit(last_completed_batch) if last_completed_batch
      end
    end

    def process_batch(batch, block)
      for index in (0...batch.size)
        msg = batch[index]

        begin
          block.call(msg)
        rescue => ex
          @error_handler.call(ex, msg)
        end

        @completed_count.increment
      end

      batch.complete
    end

    def busy_wait(consumer)
      commit_completions(consumer)

      # We exceeded the pool's queue, so busy-wait and retry
      # TODO: more intelligent busy-waiting strategy
      sleep BUSY_WAIT_INTERVAL
    end
  end
end
