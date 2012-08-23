module EQ::Queueing
  
  # this class basically provides a API that wraps the low-level calls
  # to the queueing backend that is configured and passed to the #initialize method
  # furthermore this class adds some functionality to serialize / deserialze
  # using the Job class
  class Queue
    extend SingleForwardable

    include Celluloid
    include EQ::Logging

    attr_reader :queue
    
    # @param [Object] queue_backend
    def initialize queue_backend
      @queue = queue_backend
    end

    # @param [Array<Class, *payload>] unserialized_payload
    # @return [Fixnum] job_id 
    def push *unserialized_payload
      debug "enqueing #{unserialized_payload.inspect} ..."
      queue.push EQ::Job.dump(unserialized_payload)
    end

    # @return [EQ::Job, nilClass] job instance
    def reserve
      requeue_timed_out_jobs
      if serialized_job = queue.reserve
        job_id, serialized_payload = *serialized_job
        job = EQ::Job.load job_id, serialized_payload
        debug "dequeud #{job.inspect}"
        job
      end
    end

    # 
    # TODO #pop method: shall we add a check, when the job is worked on, if we are the worker?
    # 
    def pop *args
      queue.pop *args
    end

    def requeue_timed_out_jobs; queue.requeue_timed_out_jobs; end

    def jobs; queue.jobs; end
    def working; queue.working; end
    def waiting; queue.waiting; end
  end
end
