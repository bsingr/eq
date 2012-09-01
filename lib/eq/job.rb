module EQ
  class Job
    class UnknownJobClassError < EQ::Error; end
    attr_reader :id, :queue, :payload

    def initialize id, queue, payload=nil
      @id = id
      @queue = queue.to_s
      @payload = payload
    end

    # calls MyJobClass.perform(*payload)
    def perform
      job_class.perform *payload
    end

    def job_class
      queue.split("::").inject(Kernel){|constant,part| constant.const_get(part)}
    rescue NameError => e
      raise UnknownJobClassError, e.to_s
    end
  end
end
