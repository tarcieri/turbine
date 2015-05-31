require "turbine/version"

require "concurrent"

require "turbine/batch"
require "turbine/consumer"
require "turbine/processor"

# Fault-tolerant multithreaded stream processing for Ruby
module Turbine
  # Consumer failed to connect to broker
  ConnectionError = Class.new(StandardError)
end
