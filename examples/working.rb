#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'all')

EQ.logger.level = Logger::Severity::INFO
EQ.config do |config|
  config[:sqlite] = "foo.sqlite"
end

def say words; EQ.logger.info(words); end

class SingleJob
  def self.perform
    say "worked!"
    sleep 0.05
  end
end

require 'timeout'
begin
  Timeout.timeout(120) do
    EQ.boot
    sleep 0.5 while EQ.working?
  end
rescue Timeout::Error
  say "shutdown: #{EQ.shutdown}"
end

