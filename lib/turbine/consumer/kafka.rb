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

        begin
          @consumer.fetch commit: false do |partition, messages|
            batch = Batch.new(messages, partition)
          end
        rescue Poseidon::Connection::ConnectionFailedError => ex
          raise ConnectionError, ex.to_s
        end

        batch
      end

      def commit(batch)
        return if batch.messages.empty?
        @consumer.commit batch.partition, batch.messages.last.offset + 1
      end

      def close
        @consumer.close
      end
    end
  end
end
