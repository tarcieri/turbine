module Turbine
  # Batches of messages to be processed
  class Batch
    def initialize(elements)
      @batch     = elements.freeze
      @completed = Concurrent::AtomicBoolean.new
    end

    def complete
      @completed.value = true
    end

    def completed?
      @completed.value
    end

    def [](n)
      @batch.at(n)
    end

    def size
      @batch.size
    end
  end
end
