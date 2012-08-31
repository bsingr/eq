require 'clockwork'

module EQ::Scheduling
  class Scheduler
    include Celluloid
    extend Clockwork

    handler do |job|
      EQ.push job if EQ.queue
    end

    def initialize config
      loop do
        Clockwork.tick
        sleep(Clockwork.config[:sleep_timeout])
        break unless Actor.current.alive?
      end
    end
  end
end
