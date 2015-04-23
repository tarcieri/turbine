# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "turbine/version"

Gem::Specification.new do |spec|
  spec.name          = "turbine"
  spec.version       = Turbine::VERSION
  spec.authors       = ["Tony Arcieri"]
  spec.email         = ["bascule@gmail.com"]

  spec.summary       = "Fault-tolerant multithreaded stream processing for Ruby"
  spec.description   = "Turbine is a performance-oriented stream processor built on Zookeeper"
  spec.homepage      = "https://github.com/tarcieri/turbine"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "poseidon"
  spec.add_runtime_dependency "zk"
  spec.add_runtime_dependency "concurrent-ruby"
  spec.add_runtime_dependency "thread_safe"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
end
