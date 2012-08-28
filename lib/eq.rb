# STDLIB
require 'ostruct'
require 'forwardable'

# rubygems
require 'celluloid'

require File.join(File.dirname(__FILE__), 'eq', 'version')
require File.join(File.dirname(__FILE__), 'eq', 'logging')
require File.join(File.dirname(__FILE__), 'eq', 'job')

module EQ
  extend SingleForwardable

  class ConfigurationError < ArgumentError; end

  DEFAULT_CONFIG = {
    queue: 'sequel',
    sequel: 'sqlite:/',
    job_timeout: 5 # in seconds
  }.freeze

module_function

  def config
    @config ||= OpenStruct.new DEFAULT_CONFIG
    yield @config if block_given?
    @config
  end

  # this boots queuing and working
  # optional: to use another queuing or working subsystem just do
  # require 'eq/working' or require 'eq/queueing' instead of require 'eq/all'
  def boot just=nil; manage :boot, just; end
  def shutdown just=nil; manage :shutdown, just; end

  def queue; EQ::Queueing.queue if queueing_loaded?; end
  def worker; EQ::Working.worker if working_loaded?; end
  def scheduler; EQ::Scheduling.scheduler if scheduling_loaded?; end

  # queue methods
  %w[ jobs waiting working
      push reserve pop
      push! pop!
      count ].each do |method_name|
    def_delegator :queue, method_name
  end

  def alive?
    alive = false
    alive &= queue.alive? if queue
    alive &= worker.alive? if worker
    alive
  end

  def logger; Celluloid.logger; end

  def queueing_loaded?; defined? EQ::Queueing; end
  def working_loaded?; defined? EQ::Working; end
  def scheduling_loaded?; defined? EQ::Scheduling; end
  
  # @param [#to_s] action is the method name to execute on all parts
  # @param [#to_s] specify just to execute the action on one part
  def manage action, just=nil
    what = just ? just.to_s : "queue work schedul"
    EQ::Queueing.send(action) if what =~ /queue/ && queueing_loaded?
    EQ::Working.send(action) if what =~ /work/ && working_loaded?
    EQ::Scheduling.send(action) if what =~ /schedu/ && working_loaded?
  end
end
