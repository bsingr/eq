module EQ::Queueing
  class Queue
    include Celluloid
    include EQ::Logging
  
    def initialize queue_adapter
      @queue = queue_adapter
    end

    def push *work
      debug "enqueing #{work.inspect} ..."
      queue.push EQ::Job.dump(*work)
    end

    def pop
      if payload = queue.pop
        job = EQ::Job.load payload
        debug "dequeud #{job.inspect}"
        job
      end
    end

    def cras
      raise StandardError, "fo"
    end

  private

    attr_reader :queue

  end
end
