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
    n.times { |i| EQ.queue.push MyJob, i }
    benchmark.report name do
      EQ.boot :worker
      sleep 0.01 until EQ.queue.count(:waiting) == 0
    end  
    EQ.shutdown
    sleep 0.05
  end
end

QueueBackendBenchmark.new(Executor.new(1000)).run
