require "spec_helper"
require "turbine/consumer/kafka"
require "turbine/rspec/kafka_helper"
require "benchmark"

RSpec.describe Turbine::Consumer::Kafka do
  MESSAGE_COUNT = 100_000

  let(:example_topic) { @example_topic }

  def with_consumer
    consumer = described_class.new(
      "my-consumer-group",
      ["localhost:9092"],
      ["localhost:2181"],
      example_topic
    )

    begin
      yield consumer
    ensure
      consumer.close
    end
  end

  before :all do
    timestamp = Time.now.strftime("%Y%m%d%H%M%S%L")

    @example_topic = "turbike-kafka-specs-#{timestamp}"
    KafkaHelper.create_topic(@example_topic)
    KafkaHelper.fill_topic(@example_topic, MESSAGE_COUNT)
  end

  after :all do
    KafkaHelper.delete_topic(@example_topic)
  end

  it "fetches batches of messages" do
    count = 0
    with_consumer do |consumer|
      rt = Benchmark.realtime do
        while count < MESSAGE_COUNT
          messages = consumer.fetch
          count += messages.size
        end
      end

      rate = "#{format('%.2f', count / rt)} msg/sec)"
      STDERR.puts("*** Performance: #{count} messages in #{format('%.2f', rt)} seconds (#{rate})")
    end

    expect(count).to eq MESSAGE_COUNT
  end
end
