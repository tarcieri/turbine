module Turbine
  # Batches of messages to be processed
  class Batch
    def initialize(elements)
      @batch     = elements.freeze
      @completed = false
    end

    def complete
      @completed = true
    end

    def completed?
      @completed
    end

    def [](n)
      @batch.at(n)
    end

    def size
      @batch.size
    end
  end
end
