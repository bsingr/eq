require 'sequel'

module EQ::QueueAdapter
  class SequelAdapter
    module Decorator
      def size
        db[:jobs].count
      end
    end
    include Decorator

    attr_reader :db
    def initialize
      @db = Sequel.sqlite
      create_table_if_not_exists!
    end

    def push payload
      db[:jobs].insert :payload => payload.to_sequel_blob
    end

    # TODO this must be a lock & delete, not a pop!!
    def pop
      db.transaction do
        job = db[:jobs].order(:id.desc).limit(1).first
        if job
          db[:jobs].where(:id => job[:id]).delete
          job[:payload]
        end
      end
    end

  private

    def create_table_if_not_exists!
      db.create_table? :jobs do
        primary_key :id
        Blob :payload
      end
    end
  end
end
