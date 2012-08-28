module EQ::Queueing
  module Backends
    class BackendLoadError < LoadError; end

  module_function

    # @params [#queue, #"#{queue}"] config
    # @raise ConfigurationError when config.queue is not supported
    def init config
      if %w[ sequel leveldb ].include? config.queue
        initialize_queue config
      else
        raise EQ::ConfigurationError, "config.queue = '#{config.queue}' is not supported!"
      end
    end

    # @raise LoadError when required gem is not available
    def initialize_queue config
      queue_config = config.send(config.queue)
      case EQ.config.queue
      when 'sequel'
        require_queue 'sequel'
        EQ::Queueing::Backends::Sequel.new queue_config
      when 'leveldb'
        require_queue 'leveldb'
        EQ::Queueing::Backends::LevelDB.new queue_config
      end
    end
    
    def require_queue queue_name
      require File.join(File.dirname(__FILE__), 'backends', queue_name)
    end
  end
end

