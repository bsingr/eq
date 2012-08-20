module EQ
  module Logging
    def debug message
      EQ.logger.debug message
    end

    def info message
      EQ.logger.info message
    end

    def log_error message
      EQ.logger.error message
    end
  end
end
