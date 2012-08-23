require 'set'

module EQ::Queueing::Backends
  class SortedSet
    class JobRecord < Struct.new(:id, :payload, :created_at, :started_working_at)
      # make it sortable by #id
      alias :'<=>' :id
    end

    class JobRecordCollection < ::SortedSet
      alias :count :size
    end

    attr_reader :jobs

    def initialize config = nil
      @config = config
      @jobs = JobRecordCollection.new
    end

    def push payload
      job = JobRecord.new(jobs.size+1, payload, Time.now)
      jobs << job
      job.id
    end

    def reserve
      if job = waiting.first
        job.started_working_at = Time.now
        return [job.id, job.payload]
      end
    end

    def pop job_id
      jobs.each do |job|
        if job.id == job_id
          jobs.delete job
          return true
        end
      end
      false
    end

    def requeue_timed_out_jobs
      # 10 seconds ago
      requeued = 0
      working.each do |job|
        if job.started_working_at <= (Time.now - EQ.config.job_timeout)
          requeued += 1
          job.started_working_at = nil
        end
      end
      requeued
    end

    def waiting
      result = JobRecordCollection.new
      jobs.each do |job|
        result << job unless job.started_working_at
      end
      result
    end

    def working
      result = JobRecordCollection.new
      jobs.each do |job|
        result << job if job.started_working_at
      end
      result
    end
  end
end
