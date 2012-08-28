#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'all')

require 'benchmark'
require 'tmpdir'

EQ.logger.level = Logger::Severity::ERROR

class MyJob
  def self.perform stuff
  end
end

class BenchmarkHelper < Struct.new(:n, :benchmark)
  def report name, &configure
    EQ.config &configure
    EQ.boot :queue
    n.times { |i| EQ.queue.push MyJob, i }
    benchmark.report name do
      EQ.boot :worker
      sleep 0.01 until EQ.queue.count(:waiting) == 0
    end  
    EQ.shutdown
    sleep 0.05
  end
end

n = 100
Benchmark.bm(50) do |b|
  helper = BenchmarkHelper.new(n, b)

  helper.report 'memory-based sqlite' do |config|
    config.queue = 'sequel'
  end

  helper.report 'file-based-sqlite' do |config|
    config.queue = 'sequel'
    config.sequel = "sqlite://#{Dir.mktmpdir}/benchmark.sqlite3"
  end

  helper.report 'leveldb' do |config|
    config.queue = 'leveldb'
    config.leveldb = Dir.mktmpdir
  end
end