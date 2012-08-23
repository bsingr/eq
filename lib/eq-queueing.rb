require File.join(File.dirname(__FILE__), 'eq')
require File.join(File.dirname(__FILE__), 'eq-queueing', 'backends')
require File.join(File.dirname(__FILE__), 'eq-queueing', 'queue')

module EQ::Queueing
  module_function

  def boot
    EQ::Queueing::Queue.supervise_as :_eq_queueing, initialize_queueing_backend
  end

  def shutdown
    queue.terminate! if queue
  end

  def queue
    Celluloid::Actor[:_eq_queueing]
  end

  # @raise ConfigurationError when EQ.config.queue is not supported
  def initialize_queueing_backend
    queue_config = EQ.config.send(EQ.config.queue)
    case EQ.config.queue
    when 'sequel'
      EQ::Queueing::Backends::Sequel.new queue_config
    else
      raise EQ::ConfigurationError, "EQ.config.queue = '#{EQ.config.queue}' is not supported!"
    end
  end
end