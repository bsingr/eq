require 'celluloid'
require File.join(File.dirname(__FILE__), 'eq', 'version')
require File.join(File.dirname(__FILE__), 'eq', 'logging')
require File.join(File.dirname(__FILE__), 'eq', 'job')
require File.join(File.dirname(__FILE__), 'eq', 'queue')
require File.join(File.dirname(__FILE__), 'eq', 'queue_adapter')
require File.join(File.dirname(__FILE__), 'eq', 'worker')
require File.join(File.dirname(__FILE__), 'eq', 'manager')

module EQ
  def self.boot
    start_queue
  end

  def self.start_queue
    EQ::Queue.supervise_as :queue, EQ::QueueAdapter::SequelAdapter.new
  end

  def self.queue
    Celluloid::Actor[:queue]
  end

  def self.logger
    Celluloid.logger
  end
end


