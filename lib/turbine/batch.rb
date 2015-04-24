require "thread_safe"
require "forwardable"

module Turbine
  # Batches of messages to be processed
  class Batch
    extend Forwardable

    def_delegators :@batch, :[], :size
    attr_reader :completed

    def initialize(*elements)
      @batch     = elements.clone.freeze
      @completed = ThreadSafe::Array.new(elements.size, false)
    end

    def complete(n)
      fail ArgumentError, "index out of bounds" if n < 0 || n >= @completed.size
      @completed[n] = true
    end

    def completed?
      @completed.all? { |element| element == true }
    end

    def inspect
      elements = @batch.zip(@completed).map do |elem, done|
        "#{elem.inspect}:#{done ? "completed" : "pending"}"
      end.join(", ")

      to_s.sub(/>\z/, " #{elements}>")
    end
  end
end
