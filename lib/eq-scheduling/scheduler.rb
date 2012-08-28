require 'clockwork'

module Clockwork
  handler do |job|
    EQ.push job if EQ.queue
  end
end

module EQ::Scheduling
  class Scheduler
    include Celluloid
    include Clockwork

    def initialize config
      #Clockwork.log "Starting clock for #{@@events.size} events: [ " + @@events.map { |e| e.to_s }.join(' ') + " ]"
      loop do
        Clockwork.tick
        sleep(Clockwork.config[:sleep_timeout])
        break unless Actor.current.alive?
      end
    end
  end
end
