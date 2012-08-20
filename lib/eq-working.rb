require File.join(File.dirname(__FILE__), 'eq')
require File.join(File.dirname(__FILE__), 'eq-working', 'worker')
require File.join(File.dirname(__FILE__), 'eq-working', 'manager')
require File.join(File.dirname(__FILE__), 'eq-working', 'system')

module EQ::Working
  module_function

  def boot
    Celluloid::Actor[:_eq_working] = EQ::Working::System.run!
  end

  def shutdown
    worker.finalize! if worker
  end

  def worker
    Celluloid::Actor[:_eq_working]
  end

  def worker_pool
    Celluloid::Actor[:_eq_working_pool]
  end
end