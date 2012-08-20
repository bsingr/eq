module EQ::Queueing
  class Queue
    include Celluloid
    include EQ::Logging

    module Decorator
      def waiting_count
        queue.waiting_count
      end

      def working_count
        queue.working_count
      end

      def waiting
        queue.waiting
      end

      def working
        queue.working
      end

      def job_count
        queue.job_count
      end
      alias :size :job_count
    end
    include Decorator
  
    def initialize queue_adapter
      @queue = queue_adapter
    end

    def push *unserialized_payload
      debug "enqueing #{unserialized_payload.inspect} ..."
      queue.push EQ::Job.dump(unserialized_payload)
    end

    def reserve
      if serialized_job = queue.reserve
        job_id, serialized_payload = *serialized_job
        job = EQ::Job.load job_id, serialized_payload
        debug "dequeud #{job.inspect}"
        job
      end
    end

    def pop job_id
      queue.pop job_id
    end

  private

    attr_reader :queue

  end
end
