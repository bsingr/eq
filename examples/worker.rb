#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'eq')

def say words; EQ.logger.debug(words); end

class WorkerApplication < Celluloid::SupervisionGroup
  # TODO celluloid: replace this with the following in the next version
  # pool Worker, as: worker_pool
  supervise EQ::Worker, as: :worker_pool, method: 'pool_link'
  supervise EQ::Manager, as: :manager
end

class SingleJob
  def self.perform id
    start = Time.now
    say "performing SingleJob #{id}!"
    raise 1 if id == 1
    5.times do
      say "  [next tick in SingleJob #{id}]"
      sleep 0.1
    end
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
      say "starting BackgroundApplication"
      EQ.boot
      background_app = WorkerApplication.run!
      sleep 0.1
      EQ.queue.push! BatchJob, 2
      begin
        EQ.queue.cras
      rescue
        sleep 0.1
        say "EQ.queue up again #{EQ.queue}"
      end
      
      say "started WorkerApplication #{background_app.inspect}"
      sleep 0.1
      # Take five, toplevel supervisor
      sleep 0.5 while background_app.alive?
      say "!!! Celluloid::SupervisionGroup WorkerApplication crashed. Restarting..."
    end
  end
rescue Timeout::Error
  say "timeout reached!"
  say "finalizing: #{background_app.finalize.inspect}" if background_app
  say 'done'
end

