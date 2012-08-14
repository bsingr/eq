#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'eq')

def say words; Celluloid.logger.info(words); end

class Worker
  include Celluloid
  def initialize
    say "started worker"
  end

  def process job
    say " -> working..."
    klass, *payload = job
    klass.perform *payload
    sleep 0.5
  end
end

class Manager
  include Celluloid
  def initialize
    say "started manager"
    loop do
      if job = EQ.queue.pop
        say "got #{job.inspect}"
        if worker = Actor[:worker_pool]
          say ' - found worker'
          worker.process! job
        else
          say ' - no worker'
        end
      else
        say 'no job'
      end
      sleep 0.01
    end
  end
end

class BackgroundApplication < Celluloid::SupervisionGroup
  # TODO celluloid: replace this with the following in the next version
  # pool Worker, as: worker_pool, size: 4
  supervise Worker, as: :worker_pool, method: 'pool_link', size: 4
  supervise Manager
end

class SingleJob
  def self.perform
    say 'performing SingleJob'
  end
end

class BatchJob
  def self.perform size
    say 'performing BatchJob'
    size.times do
      EQ.queue.push SingleJob
    end
  end
end

begin
  require 'timeout'
  background_app = nil
  EQ.queue.push BatchJob, 2
  say "enqueued BatchJob"
  Timeout.timeout(1) do
    loop do
      say "starting BackgroundApplication"
      background_app = BackgroundApplication.run!
      say "started BackgroundApplication #{background_app.inspect}"
      # Take five, toplevel supervisor
      sleep 0.5 while background_app.alive?
      say "!!! Celluloid::SupervisionGroup BackgroundApplication crashed. Restarting..."
    end
  end
rescue Timeout::Error
  say "finalizing: #{background_app.finalize.inspect}" if background_app
  say 'done'
end

