#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'queueing')

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
    EQ.boot
    benchmark.report name do
      n.times { |i| EQ.queue.push! MyJob, i }
      EQ.queue.count
    end  
    EQ.shutdown
    sleep 0.05
  end
end

n = 500
Benchmark.bm(50) do |b|
  helper = BenchmarkHelper.new(n, b)

  helper.report 'sequel with sqlite3 (in-memory)' do |config|
    config.queue = 'sequel'
  end

  helper.report 'sequel with sqlite3 (file)' do |config|
    config.queue = 'sequel'
    config.sequel = "sqlite://#{Dir.mktmpdir}/benchmark.sqlite3"
  end

  helper.report 'leveldb' do |config|
    config.queue = 'leveldb'
    config.leveldb = Dir.mktmpdir
  end
end
