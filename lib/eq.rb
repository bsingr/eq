require File.join(File.dirname(__FILE__), 'eq', 'version')
require File.join(File.dirname(__FILE__), 'eq', 'job')
require File.join(File.dirname(__FILE__), 'eq', 'queue_adapter')
require File.join(File.dirname(__FILE__), 'eq', 'queue_adapter', 'sequel_adapter')
require 'celluloid'

module EQ
  class Queue
    include Celluloid
  
    def initialize
      @queue = EQ::QueueAdapter::SequelAdapter.new
    end

    def push *work
      queue.push Job.dump(*work)
    end

    def pop
      if payload = queue.pop
        Job.load payload
      end
    end

  private

    def queue; @queue; end

  end

  def self.queue
    @queue ||= Queue.new
  end
end


