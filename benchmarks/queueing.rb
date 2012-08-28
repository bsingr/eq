#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'queue_backend_benchmark')

class MyJob
  def self.perform stuff
  end
end

class Executor < Struct.new(:n, :benchmark)
  def report name, &configure
    EQ.config &configure
    EQ.boot :queue
    benchmark.report name do
      n.times { |i| EQ.queue.push! MyJob, i }
      EQ.queue.count
    end  
    EQ.shutdown
    sleep 0.05
  end
end

QueueBackendBenchmark.new(Executor.new(1000)).run
