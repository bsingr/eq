#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'load_queueing')

require 'benchmark'
require 'tempfile'

EQ.logger.level = Logger::Severity::ERROR

class MyJob
  def self.perform stuff
  end
end

n = 1000
Benchmark.bm(50) do |b|
  EQ.boot
  b.report('memory-based sqlite') do
    n.times { |i| EQ.queue.push! MyJob, i }
    EQ.queue.waiting_count # block
  end
  EQ.shutdown

  EQ.config do |config|
    config[:sqlite] = Tempfile.new('').path
  end
  EQ.boot
  b.report('file-based sqlite') do
    n.times { |i| EQ.queue.push! MyJob, i }
    EQ.queue.waiting_count # block
  end
  EQ.shutdown
end
