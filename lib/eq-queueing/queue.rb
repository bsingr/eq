module EQ::Queueing
  class Queue
    include Celluloid
    include EQ::Logging

    %w[ job_count waiting_count working_count waiting working ].each do |method_name|
      define_method method_name do
        queue.send(method_name)
      end
    end
    alias :size :job_count
  
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
