#!/usr/bin/env ruby

puts ""
puts "QUEUEING"
system "#{File.join(File.dirname(__FILE__), 'queueing.rb')}"

puts ""
puts "WORKING"
system "#{File.join(File.dirname(__FILE__), 'working.rb')}"

puts ""
puts "BOTH"
system "#{File.join(File.dirname(__FILE__), 'parallel.rb')}"
