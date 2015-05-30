require "poseidon_cluster"

module Turbine
  module Consumer
    # Turbine consumer for the Kafka message queue
    class Kafka
      def initialize(*args)
        @consumer = Poseidon::ConsumerGroup.new(*args)
      end

      def fetch
        batch = nil

        @consumer.fetch commit: false do |_partition, messages|
          batch = Batch.new(messages)
        end

        batch
      end

      def close
        @consumer.close
      end
    end
  end
end
