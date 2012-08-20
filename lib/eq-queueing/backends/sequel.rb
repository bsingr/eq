require 'sequel'

module EQ::Queueing::Backends
  class Sequel
    include EQ::Logging

    module Decorator
      def size
        db[:jobs].count
      rescue ::Sequel::DatabaseError => e
        retry if on_error e
      end

      def working_count
        working.count
      rescue ::Sequel::DatabaseError => e
        retry if on_error e
      end

      def waiting_count
        waiting.count
      rescue ::Sequel::DatabaseError => e
        retry if on_error e
      end
    end
    include Decorator

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

    def push payload
      jobs.insert payload: payload.to_sequel_blob #, created_at: now
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    # TODO this must be a lock & delete, not a pop!!
    def reserve
      db.transaction do
        job = waiting.order(:id.desc).limit(1).first
        if job
          job[:started_working_at] = now
          update_job!(job)
          [job[:id], job[:payload]]
        end
      end
    rescue ::Sequel::DatabaseError => e
      retry if on_error e
    end

    def pop id
      jobs.where(id: id).delete
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
