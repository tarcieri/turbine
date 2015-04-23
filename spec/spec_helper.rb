require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "turbine"

RSpec.configure(&:disable_monkey_patching!)
