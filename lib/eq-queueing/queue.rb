module EQ::Queueing
  
  # this class basically provides a API that wraps the low-level calls
  # to the queueing backend that is configured and passed to the #initialize method
  # furthermore this class adds some functionality to serialize / deserialze
  # using the Job class
  class Queue
    include Celluloid
    include EQ::Logging

    %w[ job_count waiting_count working_count waiting working ].each do |method_name|
      define_method method_name do
        queue.send(method_name)
      end
    end
    alias :size :job_count
    
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
      if serialized_job = queue.reserve
        job_id, serialized_payload = *serialized_job
        job = EQ::Job.load job_id, serialized_payload
        debug "dequeud #{job.inspect}"
        job
      end
    end

    # @return [TrueClass, FalseClass]
    def pop job_id
      queue.pop job_id
    end

  private

    attr_reader :queue

  end
end
