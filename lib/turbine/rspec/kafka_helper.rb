require "open3"
require "poseidon"

# Helper functions for integration testing with Kafka
module KafkaHelper
  extend self

  ZOOKEEPER_ADDR = "localhost:2181"
  KAFKA_ADDR     = "localhost:9092"

  def delete_topic(topic)
    STDERR.puts("*** Deleting Kafka topic: #{topic}")

    topic_command :delete, topic: topic
  end

  def create_topic(topic)
    STDERR.puts("*** Creating Kafka topic: #{topic}")

    required_topic_command :create,
                           "replication-factor" => 1,
                           "partitions"         => 1,
                           "topic"              => topic
  end

  def list_topics
    topic_command(:list).split("\n")
  end

  def topic_exists?(topic)
    list_topics.include?(topic)
  end

  def fill_topic(topic, n = 100_000)
    fail ArgumentError, "min messages is 1000" if n < 1000

    producer = Poseidon::Producer.new([KAFKA_ADDR], "my_test_producer", type: :sync)

    STDERR.puts("*** Filling topic with #{n} messages: #{topic}")

    (n / 1000).times do |i|
      messages = []

      1000.times do |j|
        n = (i * 1000 + j)
        messages << Poseidon::MessageToSend.new(topic, n.to_s)
      end

      producer.send_messages(messages)
    end
  ensure
    producer.close if producer
  end

  private

  def kafka_path
    File.expand_path("../../../../kafka", __FILE__)
  end

  def kafka_topics_bin_path
    "#{kafka_path}/bin/kafka-topics.sh"
  end

  def kafka_args(args = {})
    { zookeeper: ZOOKEEPER_ADDR }.merge(args).map { |k, v| "--#{k} #{v}" }.join(" ")
  end

  def topic_command(command, args = {})
    cmd = "#{kafka_topics_bin_path} --#{command} #{kafka_args(args)}"
    stdout_str, _stderr_str, status = Open3.capture3(cmd)
    return unless status.success?
    stdout_str
  end

  def required_topic_command(command, args = {})
    result = topic_command(command, args)
    fail "Kafka command failed!" unless result
    true
  end
end
