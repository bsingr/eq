#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'all')

# Define a Job class with a perform method.
class MyJob
  RESULT_PATH = 'my_job_result.txt'

  def self.perform enqueued_at, workload_in_seconds
    # do some long running stuff here
    sleep workload_in_seconds
    File.open RESULT_PATH, 'a' do |file|
      finished_at = Time.now
      file.puts "Processed a job with workload of #{workload_in_seconds}s:\n"\
                " - enqueued at     = #{enqueued_at}\n"\
                " - finished at     = #{finished_at}\n"\
                " - actual workload = #{finished_at - enqueued_at}s"
    end
  end
end

# Cleanup results file.
File.delete MyJob::RESULT_PATH if File.exists? MyJob::RESULT_PATH

# Start the EQ system.
EQ.boot

# Enqueue some work.
EQ.queue.push MyJob, Time.now, 1
EQ.queue.push MyJob, Time.now, 2

# Wait some time to get the work done.
sleep 3

# Read the results file.
puts File.read MyJob::RESULT_PATH
