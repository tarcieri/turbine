require "forwardable"
require "poseidon"

module Turbine
  module Consumer
    # Turbine consumer for the Kafka message queue
    class Kafka
      extend Forwardable

      def_delegators :@consumer, :fetch, :close

      def initialize(*args)
        @consumer = Poseidon::PartitionConsumer.new(*args)
      end
    end
  end
end
