module EQ
  class Job < Struct.new(:id, :serialized_payload)
    class << self
      def dump *unserialized_payload
        Marshal.dump(unserialized_payload.flatten)
      end

      def load id, serialized_payload
        Job.new id, serialized_payload
      end
    end

    def unpack
      #[const_name.split("::").inject(Kernel){|res,current| res.const_get(current)}, *payload]
      Marshal.load(serialized_payload)
    end

    def perform
      const, *payload = unpack
      const.perform *payload
    end
  end
end
