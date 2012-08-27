# EXPERIMENTAL FOO, THE DEVILS RIDE...

# EQ - Embedded Queueing

EQ is a little framework to queue tasks within a process.

[![Travis-CI Build Status](https://secure.travis-ci.org/dpree/eq.png)](https://secure.travis-ci.org/dpree/eq)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/dpree/eq)

## Installation

Install it yourself using Rubygems.

    $ gem install eq

Or use something like [Bundler](http://gembundler.com/).

## Example

If you want to execute a simple example you can just run [examples/simple_usage.rb](./examples/simple_usage.rb) from your commandline.

**1. Define a Job class with a perform method.**

	class MyJob
	  def self.perform *some_args
	    # do some long running stuff here
	  end
	end

**2. Start the EQ system.**

	EQ.boot
	
**3. Let EQ do some work you.**

	EQ.push MyJob, 'foo'
	EQ.push MyJob, 'bar'
	…	

## Configuration

Right now there are two queueing backends available, one that is based on the Sequel gem and one based on LevelDB. With Sequel basically any SQL database might be used. Just make sure that you install the Backend before running the application.

### Sequel

Gemfile

	gem 'sequel'
	gem 'sqlite3'

Configuration

	EQ.config.queue = 'sequel'
	
	# With SQLite3 in-memory (default) using String syntax
	EQ.config.sequel = 'sqlite:/' 
	
	# With SQLite3 file using Hash syntax
	EQ.config.sequel = {adapter: 'sqlite', database: 'my_db.sqlite3'}
	
	# With Postgres
	EQ.config.sequel = 'postgres://user:password@host:port/my_db'
	
	# Mysql, Oracle, etc.
	# ...

# LevelDB

Gemfile

	gem 'leveldb-ruby'

Configuration

	EQ.config.queue = 'leveldb'
	EQ.config.leveldb = 'path/to/my/queue.leveldb'

### Logging

EQ uses the logging mechanism of the underlying Celluloid (`Celluloid.logger`) framework. Basically you can just bind it to your application logger or re-configure it (see the Documentation of the `Logger` class from Ruby Standard Library).

**Changing the Logger:**

	# Use the logger of your Rails application.
	Celluloid.logger = Rails.logger
	
	# No logging at all.
	Celluloid.logger = Logger.new('/dev/null')

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# LICENSE

Copyright (c) 2012 Jens Bissinger. See [LICENSE](LICENSE).

