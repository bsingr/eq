#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'queueing')

EQ.logger.level = Logger::Severity::INFO
EQ.config do |config|
  config.sequel = "sqlite://foo.sqlite"
end

def say words; EQ.logger.info(words); end

class SingleJob
  def self.perform
    sleep 0.05
  end
end

require 'timeout'
begin
  Timeout.timeout(10) do
    EQ.boot
    loop do
      say "pushed!"
      sleep 0.05
      EQ.queue.push! SingleJob
    end
  end
rescue Timeout::Error
  say "shutdown: #{EQ.shutdown}"
end

