module EQ::Working
  class Worker
    include Celluloid
    include EQ::Logging

    def initialize
      debug "started worker"
    end

    def process job
      debug " -> working..."
      job.perform
      EQ.queue.pop job.id
    end
  end
end
