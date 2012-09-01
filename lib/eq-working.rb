require File.join(File.dirname(__FILE__), 'eq')
require File.join(File.dirname(__FILE__), 'eq-working', 'worker')

module EQ::Working
  module_function

  EQ_WORKER = :_eq_working

  def boot
    Celluloid::Actor[EQ_WORKER] = EQ::Working::Worker.pool
  end

  def shutdown
    worker.terminate! if worker
  end

  def worker
    Celluloid::Actor[EQ_WORKER]
  end

  def pool_size
    Celluloid.cores
  end
end