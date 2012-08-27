require File.join(File.dirname(__FILE__), 'eq')
require File.join(File.dirname(__FILE__), 'eq-queueing', 'backends')
require File.join(File.dirname(__FILE__), 'eq-queueing', 'queue')

module EQ::Queueing
  module_function

  EQ_QUEUE = :_eq_queueing

  def boot
    EQ::Queueing::Queue.supervise_as EQ_QUEUE, EQ::Queueing::Backends.init(EQ.config)
  end

  def shutdown
    queue.terminate! if queue
  end

  def queue
    Celluloid::Actor[EQ_QUEUE]
  end
end