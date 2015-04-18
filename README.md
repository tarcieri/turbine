![Turbine](https://raw.githubusercontent.com/tarcieri/turbine/master/turbine.png)
=======
[![Build Status](https://travis-ci.org/tarcieri/turbine.svg)](https://travis-ci.org/tarcieri/turbine)

Fault-tolerant multithreaded stream processing for Ruby.

Turbine is a perforance-oriented stream processing library built on Zookeeper.
It presently supports Kafka as a message queue, but is designed to be pluggable
in order to potentially support other message queues in the future.

Turbine is not a job queue and is missing most of the features you'd expect
from a job queue by design. Turbine is designed to be small, simple, and fast.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'turbine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install turbine

## Usage

Coming soon!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

* Fork this repository on github
* Make your changes and send us a pull request
* If we like them we'll merge them
* If we've accepted a patch, feel free to ask for commit access

## License

Copyright (c) 2015 Tony Arcieri. Distributed under the MIT License. See
LICENSE.txt for further details.
