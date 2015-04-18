require "rake/clean"
require "colorize"

def zookeeper_config(data)
  <<-CONFIG
# Zookeeper configuration

# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
dataDir=#{data}
# the port at which the clients will connect
clientPort=2181
CONFIG
end

namespace :zookeeper do
  ZK_VERSION = "3.4.6"
  ZK_TARBALL = "zookeeper-#{ZK_VERSION}.tar.gz"

  task download: "tmp/#{ZK_TARBALL}"
  directory "tmp"

  file "tmp/#{ZK_TARBALL}" => "tmp" do
    puts "#{'***'.blue} #{'Downloading Zookeeper'.light_white}"
    url = "https://archive.apache.org/dist/zookeeper/zookeeper-#{ZK_VERSION}/#{ZK_TARBALL}"
    sh "curl #{url} -o tmp/#{ZK_TARBALL}"
  end

  task install: :download do
    puts "#{'***'.blue} #{'Unpacking Zookeeper'.light_white}"

    rm_rf "zookeeper" if File.exist? "zookeeper"
    sh "tar -zxvf tmp/#{ZK_TARBALL}"
    mv "zookeeper-#{ZK_VERSION}", "zookeeper"
    home = File.expand_path("../../zookeeper", __FILE__)

    # Create base configuration
    data = File.join(home, "data")
    mkdir_p data
    config = File.join(home, "conf", "zoo.cfg")
    rm_r File.join(home, "conf", "zoo_sample.cfg")

    File.open(config, "w") { |file| file << zookeeper_config(data) }
  end

  task start: :zookeeper do
    puts "#{'***'.blue} #{'Starting Zookeeper'.light_white}"
    sh "cd zookeeper && bin/zkServer.sh start"
  end
end

file "zookeeper" do
  Rake::Task["zookeeper:install"].invoke
end

CLEAN.include "tmp", "zookeeper"
