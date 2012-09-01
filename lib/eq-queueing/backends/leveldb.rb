require 'leveldb'

module EQ::Queueing::Backends

  # @note This is a unoreded storage, so there is no guaranteed work order
  # @note assume there is nothing else than jobs
  class LevelDB
    class JobsCollection < Struct.new(:db, :name)
      include EQ::Logging

      QUEUE              = 'queue'.freeze
      PAYLOAD            = 'payload'.freeze
      CREATED_AT         = 'created_at'.freeze
      STARTED_WORKING_AT = 'started_working_at'.freeze
      NOT_WORKING = ''.freeze

      # @param [EQ::Job] job
      def push job
        job_id = find_free_job_id
        db["#{QUEUE}:#{job_id}"] = job.queue
        db["#{PAYLOAD}:#{job_id}"] = serialize(job.payload) unless job.payload.nil?
        db["#{CREATED_AT}:#{job_id}"] = serialize(Time.now)
        db["#{STARTED_WORKING_AT}:#{job_id}"] = NOT_WORKING
        job_id
      end

      def first_waiting
        db.each do |k,v|
          if k.include?(STARTED_WORKING_AT) && v == NOT_WORKING
            return job_id_from_key(k)
          end
        end
        nil
      end

      def working_iterator
        db.each do |k,v|
          if k.include?(STARTED_WORKING_AT) && v != NOT_WORKING
            yield job_id_from_key(k), deserialize(v)
          end
        end
      end

      # @param [EQ::Job] job without id
      def exists? job
        db.each do |k,v|
          if k.include?(QUEUE) && v == job.queue
            if find_payload(job_id_from_key(k)) == job.payload
              return true
            end
          end
        end
        false
      end

      def delete job_id
        did_exist = !db["#{QUEUE}:#{job_id}"].nil?
        db.batch do |batch|
          batch.delete "#{QUEUE}:#{job_id}"
          batch.delete "#{PAYLOAD}:#{job_id}"
          batch.delete "#{CREATED_AT}:#{job_id}"
          batch.delete "#{STARTED_WORKING_AT}:#{job_id}"
        end
        does_not_exist = db["#{QUEUE}:#{job_id}"].nil?
        did_exist && does_not_exist
      end

      def start_working job_id
        db["#{STARTED_WORKING_AT}:#{job_id}"] = serialize(Time.now)
      end

      def stop_working job_id
        db["#{STARTED_WORKING_AT}:#{job_id}"] = NOT_WORKING
      end

      def find_queue job_id
        db["#{QUEUE}:#{job_id}"]
      end

      def find_payload job_id
        if raw = db["#{PAYLOAD}:#{job_id}"]
          deserialize db["#{PAYLOAD}:#{job_id}"]
        else
          nil
        end
      end

      def find_created_at job_id
        if serialized_time = db["#{CREATED_AT}:#{job_id}"]
          deserialize(serialized_time)
        end
      end

      def find_started_working_at job_id
        if serialized_time = db["#{STARTED_WORKING_AT}:#{job_id}"]
          deserialize(serialized_time)
        end
      end

      def job_id_from_key key
        prefix, job_id = *key.split(':')
        job_id
      end

      # try as hard as you can to find a free slot
      def find_free_job_id
        loop do
          job_id = generate_id
          return job_id unless db.contains? "#{QUEUE}:#{job_id}"
          debug "#{job_id} is not free"
        end
      end

      # Time in milliseconds and 4 digit random
      # @note Maybe this is a stupid idea, but for now it kinda works :)
      def generate_id
        '%d%04d' % [(Time.now.to_f * 1000.0).to_i, Kernel.rand(1000)]
      end

      def serialize data
        Marshal.dump(data)
      end

      def deserialize data
        Marshal.load(data)
      end

      def count
        result = 0
        db.each do |k,v|
          result += 1 if k.include?(QUEUE)
        end
        result
      end

      def count_waiting
        result = 0
        db.each do |k,v|
          if k.include?(STARTED_WORKING_AT) && v == NOT_WORKING
            result += 1
          end
        end
        result
      end

      def count_working
        result = 0
        db.each do |k,v|
          if k.include?(STARTED_WORKING_AT) && v != NOT_WORKING
            result += 1
          end
        end
        result
      end
    end

    attr_reader :db
    attr_reader :jobs

    def initialize config
      @db = ::LevelDB::DB.new config
      @jobs = JobsCollection.new(db)
    end

    # @param [EQ::Job] job
    def push job
      if job.unique? && jobs.exists?(job)
        false
      else
        jobs.push job
      end
    end

    def reserve
      if job_id = jobs.first_waiting
        jobs.start_working job_id
        EQ::Job.new job_id, jobs.find_queue(job_id), jobs.find_payload(job_id)
      end
    end

    def pop job_id
      jobs.delete job_id
    end

    def requeue_timed_out_jobs
      requeued = 0
      jobs.working_iterator do |job_id, started_working_at|
        # older than x
        if started_working_at <= (Time.now - EQ.config.job_timeout)
          jobs.stop_working job_id
          requeued += 1
        end
      end
      requeued
    end

    def count name=nil
      case name
      when :waiting
        jobs.count_waiting
      when :working
        jobs.count_working
      else
        jobs.count
      end
    end
  end
end
