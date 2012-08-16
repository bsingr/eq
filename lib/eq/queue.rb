module EQ
  class Queue
    include Celluloid
    include Logging
  
    def initialize queue_adapter
      @queue = queue_adapter
    end

    def push *work
      queue.push Job.dump(*work)
    end

    def pop
      if payload = queue.pop
        Job.load payload
      end
    end

    def cras
      raise StandardError, "fo"
    end

  private

    attr_reader :queue

  end
end
