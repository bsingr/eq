require 'celluloid'

require File.join(File.dirname(__FILE__), 'eq', 'version')
require File.join(File.dirname(__FILE__), 'eq', 'logging')
require File.join(File.dirname(__FILE__), 'eq', 'job')

module EQ
  module_function

  def config
    @config ||= {}
    yield @config if block_given?
    @config
  end

  # this boots queuing and working
  # optional: to use another queuing or working subsystem just do
  # require 'eq/working' or require 'eq/queueing' instead of require 'eq/all'
  def boot
    boot_queueing if defined? EQ::Queueing
    boot_working if defined? EQ::Working
  end

  def shutdown
    EQ::Working.shutdown if defined? EQ::Working
    EQ::Queueing.shutdown if defined? EQ::Queueing
  end

  def boot_queueing
    EQ::Queueing.boot
  end

  def boot_working
    EQ::Working.boot
  end

  def queue
    EQ::Queueing.queue
  end

  def worker
    EQ::Working.worker
  end

  def queueing?
    queue.alive?
  end

  def working?
    worker.alive?
  end

  def logger
    Celluloid.logger
  end
end
