module EQ::Working
  class Manager
    include Celluloid
    include EQ::Logging

    def initialize
      run!
    end

    def run
      debug "manager running"
      loop do
        if EQ.queue && job = EQ.queue.reserve
          debug "got #{job.inspect}"
          if worker = EQ::Working.worker_pool
            debug ' - found worker'
            worker.process! job
          else
            debug ' - no worker'
          end
        else
          #debug 'no job'
        end
        sleep 0.01
      end
    rescue Celluloid::DeadActorError
      retry
    end
  end
end
