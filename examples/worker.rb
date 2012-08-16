#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'load_all')

def say words; EQ.logger.debug(words); end

class SingleJob
  def self.perform id
    start = Time.now
    say "performing SingleJob #{id}!"
    raise "job 1 will die" if id == 1
    5.times do
      say "[next tick in SingleJob #{id}]"
    end
    sleep 0.01
    took = (((Time.now.to_f - start.to_f)*100).to_i.to_f/100)
    say "SingleJob #{id} was done in #{took} seconds!"
  end
end

class BatchJob
  def self.perform size
    say 'performing BatchJob'
    size.times do |i|
      EQ.queue.push SingleJob, i
      sleep 0.2
    end
  end
end

begin
  require 'timeout'
  background_app = nil
  say "enqueued BatchJob"
  Timeout.timeout(2) do
    loop do
      say "booting"
      EQ.boot
      say " - successfully booted"
      sleep 0.1
      EQ.queue.push! BatchJob, 3
      begin
        #EQ.queue.cras
      rescue
        sleep 0.1
        say "EQ.queue up again #{EQ.queue}"
      end
      
      say "started WorkerApplication #{EQ.worker.inspect}"
      sleep 0.1
      # Take five, toplevel supervisor
      sleep 0.5 while EQ.worker.alive?
      say "!!! Celluloid::SupervisionGroup WorkerApplication crashed. Restarting..."
    end
  end
rescue Timeout::Error
  say "timeout reached!"
  say "finalizing: #{EQ.worker.finalize!.inspect}" if EQ.worker
  say "finalizing: #{EQ.queue.finalize!.inspect}" if EQ.queue
  say 'done'
end

