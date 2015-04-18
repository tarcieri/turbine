require "bundler/gem_tasks"

Dir["tasks/**/*.rake"].each { |task| load task }

task default: [:spec, :rubocop]
task ci:      [:spec, :rubocop]
