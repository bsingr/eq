module EQ
  class Worker
    include Celluloid
    include Logging

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
