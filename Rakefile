require "bundler/gem_tasks"

Dir["tasks/**/*.rake"].each { |task| load task }

task default: %w(spec rubocop)
task ci:      %w(kafka:start spec rubocop)
