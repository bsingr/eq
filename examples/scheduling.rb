#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'all')

class MyJob
  def self.perform
    puts 'perfoming...'
  end
end

module Clockwork
  every(1.seconds, MyJob)
  every(1.day, MyJob, :at => '00:00')
end

EQ.boot

sleep 3

EQ.shutdown
