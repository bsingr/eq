require File.join(File.dirname(__FILE__), 'eq')
require File.join(File.dirname(__FILE__), 'eq-working', 'worker')

module EQ::Working
  module_function

  EQ_WORKER = :_eq_working

  def boot
    pool_size =EQ.config.worker_pool_size
    case pool_size
    when 0
      puts "pool empty"
    when 1
      EQ::Working::Worker.supervise_as EQ_WORKER
    else
      Celluloid::Actor[EQ_WORKER] = EQ::Working::Worker.pool size: pool_size
    end
  end

  def shutdown
    worker.terminate! if worker
  end

  def worker
    Celluloid::Actor[EQ_WORKER]
  end

  def pool_size
    EQ.config.worker_pool_size
  end
end