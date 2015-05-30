module Turbine
  # Batches of messages to be processed
  class Batch
    attr_reader :messages, :partition

    def initialize(messages, partition)
      @messages  = messages.freeze
      @partition = partition
      @completed = Concurrent::AtomicBoolean.new
    end

    def complete
      @completed.value = true
    end

    def completed?
      @completed.value
    end

    def [](n)
      @messages.at(n)
    end

    def size
      @messages.size
    end
  end
end
