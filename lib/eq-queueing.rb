require File.join(File.dirname(__FILE__), 'eq')
require File.join(File.dirname(__FILE__), 'eq-queueing', 'backends')
require File.join(File.dirname(__FILE__), 'eq-queueing', 'queue')

module EQ::Queueing
  module_function

  def boot
    EQ::Queueing::Queue.supervise_as :_eq_queueing, EQ::Queueing::Backends::Sequel.new
  end

  def shutdown
    queue.terminate! if queue
  end

  def queue
    Celluloid::Actor[:_eq_queueing]
  end
end