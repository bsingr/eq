#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'queueing')

require 'benchmark'
require 'tempfile'
require 'tmpdir'

Celluloid.logger = Logger.new('/dev/null')
#EQ.logger.level = Logger::Severity::ERROR

class MyJob
  def self.perform stuff
  end
end

n = 1_000
Benchmark.bm(50) do |b|
  EQ.boot
  b.report('memory-based sqlite') do
    n.times { |i| EQ.queue.push! MyJob, i }
    EQ.queue.count
  end
  EQ.shutdown
  sleep 0.05

  EQ.config do |config|
    config.sqlite = Tempfile.new('').path
  end
  EQ.boot
  b.report('file-based sqlite') do
    n.times { |i| EQ.queue.push! MyJob, i }
    EQ.queue.count
  end
  EQ.shutdown
  sleep 0.05

  EQ.config do |config|
    config.queue = 'sorted_set'
  end
  EQ.boot
  b.report('sorted set') do
    n.times { |i| EQ.queue.push! MyJob, i }
    EQ.queue.count
  end
  EQ.shutdown
  sleep 0.05

  EQ.config do |config|
    config.queue = 'leveldb'
    config.leveldb = Dir.mktmpdir
  end
  EQ.boot
  b.report('leveldb') do
    n.times { |i| EQ.queue.push! MyJob, i }
    EQ.queue.count
  end
  EQ.shutdown
  sleep 0.05

end
