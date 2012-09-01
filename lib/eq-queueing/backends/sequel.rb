require 'sequel'

module EQ::Queueing::Backends

  # this class provides a queueing backend via Sequel ORM mapper
  # basically any database adapter known by Sequel is supported
  # configure via EQ::conig[:sequel]
  class Sequel
    include EQ::Logging

    TABLE_NAME = :jobs

    attr_reader :db

    # establishes the connection to the database and ensures that
    # the jobs table is created
    def initialize config
      connect config
      create_table_if_not_exists!
    end

    # @param [EQ::Job] payload
    # @return [Fixnum] id of the job
    def push eq_job
      job = {queue: eq_job.queue, created_at: Time.now}
      job[:payload] = Marshal.dump(eq_job.payload).to_sequel_blob unless eq_job.payload.nil?
      jobs.insert job
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # pulls a job from the waiting stack and moves it to the
    # working stack. sets a timestamp :started_working_at so that
    # the working duration can be tracked.
    # @param [Time] now
    # @return [Array<Fixnum, String>] job data consisting of id and payload
    def reserve
      db.transaction do
        if job = waiting.order(:id).last # asc
          job[:started_working_at] = Time.now
          update_job!(job)
          payload = job[:payload].nil? ? nil : Marshal.load(job[:payload])
          EQ::Job.new(job[:id], job[:queue], payload)
        end
      end
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # finishes a job in the working queue
    # @param [Fixnum] id of the job
    # @return [TrueClass, FalseClass] true, when there was a job that could be deleted
    def pop id
      jobs.where(id: id).delete == 1
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # list of jobs waiting to be worked on
    def waiting
      jobs.where(started_working_at: nil)
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # list of jobs currentyl being worked on
    def working
      waiting.invert
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # list of all jobs
    def jobs
      db[TABLE_NAME]
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # updates a changed job object, uses the :id key to identify the job
    # @param [Hash] changed job
    def update_job! changed_job
      jobs.where(id: changed_job[:id]).update(changed_job)
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # this re-enqueues jobs that timed out
    # @return [Fixnum] number of jobs that were re-enqueued
    def requeue_timed_out_jobs
      # older than x
      jobs.where{started_working_at <= (Time.now - EQ.config.job_timeout)}\
          .update(started_working_at: nil)
    end

    def count name=nil
      case name
      when :waiting
        waiting.count
      when :working
        working.count
      else
        jobs.count
      end
    end

  private

    # connects to the given database config
    def connect config
      @db = ::Sequel.connect config
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    def create_table_if_not_exists!
      db.create_table? TABLE_NAME do
        primary_key :id
        String :queue
        Timestamp :created_at
        Timestamp :started_working_at
        Blob :payload
      end
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    def on_error error
      log_error error.inspect
      sleep 0.05
      true
    end
  end
end
