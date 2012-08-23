#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'all')

require 'benchmark'
require 'tempfile'

EQ.logger.level = Logger::Severity::ERROR

class MyJob
  def self.perform stuff
  end
end

n = 500
Benchmark.bm(50) do |b|
  EQ.boot_queueing
  n.times { |i| EQ.queue.push! MyJob, i }
  b.report('memory-based sqlite') do
    EQ.boot_working
    sleep 0.01 until EQ.queue.waiting.count == 0
  end
  EQ.shutdown

  EQ.config do |config|
    config[:sqlite] = Tempfile.new('').path
  end
  EQ.boot_queueing
  n.times { |i| EQ.queue.push! MyJob, i }
  b.report('file-based sqlite') do
    EQ.boot_working
    sleep 0.01 until EQ.queue.waiting.count == 0
  end
  EQ.shutdown
end
