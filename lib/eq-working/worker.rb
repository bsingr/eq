module EQ::Working
  class Worker
    include Celluloid
    include EQ::Logging

    def initialize
      debug "initialized worker"
    end

    # @param [EQ::Job] job instance
    # @return [TrueClass, FalseClass] true when job is done and deleted
    def process job
      debug "processing #{job.inspect}"
      job.perform
      EQ.queue.pop job.id
    end
  end
end
