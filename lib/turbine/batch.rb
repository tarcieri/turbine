require "forwardable"

module Turbine
  # Batches of messages to be processed
  class Batch
    extend Forwardable

    def_delegators :@batch, :[], :size

    def initialize(*elements)
      @batch     = elements.clone.freeze
      @completed = Array.new(elements.size).fill { Concurrent::AtomicBoolean.new }.freeze
    end

    def complete(n)
      fail ArgumentError, "index out of bounds" if n < 0 || n >= @completed.size
      @completed[n].value = true
    end

    def completed?
      @completed.all? { |element| element.value == true }
    end

    def inspect
      elements = @batch.zip(@completed).map do |elem, completed|
        "#{elem.inspect}:#{completed.value ? 'completed' : 'pending'}"
      end.join(", ")

      to_s.sub(/>\z/, " #{elements}>")
    end
  end
end
