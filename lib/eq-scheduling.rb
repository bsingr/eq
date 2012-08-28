require File.join(File.dirname(__FILE__), 'eq')
require File.join(File.dirname(__FILE__), 'eq-scheduling', 'scheduler')

module EQ::Scheduling
  module_function

  EQ_SCHEDULER = :_eq_scheduler

  def boot
    EQ::Scheduling::Scheduler.supervise_as EQ_SCHEDULER, EQ.config
  end

  def shutdown
    scheduler.terminate! if scheduler
  end

  def scheduler
    Celluloid::Actor[EQ_SCHEDULER]
  end
end
