module EQ
  module Logging
    def debug message
      EQ.logger.info message
      STDOUT.flush
    end
  end
end
