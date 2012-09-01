module EQ::Scheduling
  class Scheduler
    include EQ::Logging
    include Celluloid

    def initialize config
      clockwork!
    end

    def clockwork
      debug 'scheduler running'
      loop do
        Clockwork.tick
        sleep(Clockwork.config[:sleep_timeout])
        return unless Actor.current.alive?
      end
    end
  end
end
