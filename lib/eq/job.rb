module EQ
  class Job
    attr_reader :id, :payload

    def initialize id, queue, payload=nil
      @id = id
      @queue = queue
      @payload = payload
    end

    def queue
      if @queue.is_a? String
        @queue.split("::").inject(Kernel){|constant,part| constant.const_get(part)}
      else
        @queue
      end
    end

    def queue_str
      @queue.to_s
    end

    # calls MyJobClass.perform(*payload)
    def perform
      queue.perform *payload
    end
  end
end
