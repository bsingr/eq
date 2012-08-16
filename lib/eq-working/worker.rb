module EQ::Working
  class Worker
    include Celluloid
    include EQ::Logging

    def initialize
      debug "started worker"
    end

    def process job
      debug " -> working..."
      klass, *payload = job
      klass.perform *payload
    end
  end
end
