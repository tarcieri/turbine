require "poseidon"

module Turbine
  module Consumer
    # Turbine consumer for the Kafka message queue
    class Kafka
      def initialize(*args)
        @consumer = Poseidon::PartitionConsumer.new(*args)
      end

      def fetch
        Batch.new(@consumer.fetch)
      end

      def close
        @consumer.close
      end
    end
  end
end
