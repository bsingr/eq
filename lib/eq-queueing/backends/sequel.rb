require 'sequel'

module EQ::Queueing::Backends
  class Sequel
    include EQ::Logging

    attr_reader :db
    def initialize
      if sqlite_file = EQ.config[:sqlite] 
        @db = ::Sequel.sqlite sqlite_file
      else
        @db = ::Sequel.sqlite
      end
      create_table_if_not_exists!      
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # @param [#to_sequel_block] payload
    # @return [Fixnum] id of the job
    def push payload
      jobs.insert payload: payload.to_sequel_blob, created_at: now
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # pulls a job from the waiting stack and moves it to the
    # working stack. sets a timestamp :started_working_at so that
    # the working duration can be tracked.
    # @return [Array<Fixnum, String>] job data consisting of id and payload
    def reserve
      db.transaction do
        job = waiting.order(:id.asc).limit(1).first
        if job
          job[:started_working_at] = now
          update_job!(job)
          [job[:id], job[:payload]]
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

    def waiting
      jobs.where(started_working_at: nil)
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    def working
      waiting.invert
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    def jobs
      db[:jobs]
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    def update_job! changed_job
      db[:jobs].where(id: changed_job[:id]).update(changed_job)
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # statistics:
    #   - #job_count
    #   - #working_count
    #   - #waiting_count
    %w[ job working waiting ].each do |stats_name|
      define_method "#{stats_name}_count" do
        begin
          send(stats_name).send(:count)
        rescue ::Sequel::DatabaseError => e
          retry if on_error e
        end
      end
    end

  private

    def now
      Time.now
    end

    def create_table_if_not_exists!
      db.create_table? :jobs do
        primary_key :id
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
