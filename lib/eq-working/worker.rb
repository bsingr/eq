module EQ::Working
  class Worker
    include Celluloid
    include EQ::Logging

    def initialize autostart=true
      # start working async
      run! if autostart
    end

    def run
      # TODO check if this is really what we want here, does it stop gracefully?
      while Celluloid::Actor.current.alive?
        if job = look_for_a_job
          debug "got #{job.inspect}"
          
          # this should happen in sync mode, because we don't want to pick
          # too much jobs
          process job
        else
          # currently no job
          sleep 0.05
        end
      end
    rescue Celluloid::DeadActorError
      log_error 'dead'
      sleep 0.05
      retry
    end

    def look_for_a_job
      EQ.queue.reserve if EQ.queue && EQ.queue.alive?
    end

    # @param [EQ::Job] job instance
    # @return [TrueClass, FalseClass] true when job is done and deleted
    def process job
      debug "processing #{job.inspect}"
      job.perform
      EQ.queue.pop! job.id
    end
  end
end
