require "rake/clean"
require "colorize"
require "socket"
require "timeout"

KAFKA_PORT    = 9092
START_TIMEOUT = 5

namespace :kafka do
  KAFKA_VERSION = "0.8.2.1"
  KAFKA_TARBALL = "kafka_2.10-#{KAFKA_VERSION}.tgz"

  task download: "tmp/#{KAFKA_TARBALL}"
  directory "tmp"

  file "tmp/#{KAFKA_TARBALL}" => "tmp" do
    puts "#{'***'.blue} #{'Downloading Kafka'.light_white}"
    url = "https://www.apache.org/dist/kafka/#{KAFKA_VERSION}/kafka_2.10-#{KAFKA_VERSION}.tgz"
    sh "curl #{url} -o tmp/#{KAFKA_TARBALL}"
  end

  task install: :download do
    puts "#{'***'.blue} #{'Unpacking Kafka'.light_white}"

    rm_rf "kafka" if File.exist? "kafka"
    sh "tar -zxf tmp/#{KAFKA_TARBALL}"
    mv "kafka_2.10-#{KAFKA_VERSION}", "kafka"
  end

  task start: %w(kafka zookeeper:start) do
    puts "#{'***'.blue} #{'Starting Kafka'.light_white}"
    sh "cd kafka && bin/kafka-server-start.sh config/server.properties &"

    Timeout.timeout(START_TIMEOUT) do
      begin
        socket = TCPSocket.open("localhost", 9092)
      rescue Errno::ECONNREFUSED
        sleep 0.01
        retry
      end

      socket.close
    end

    # Give Kafka some time to finish printing startup messages
    sleep 0.5
    puts "#{'***'.blue} #{'Kafka started!'.light_white}"
  end
end

file "kafka" do
  Rake::Task["kafka:install"].invoke
end

CLEAN.include "tmp", "kafka"
