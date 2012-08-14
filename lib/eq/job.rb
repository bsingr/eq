module EQ
  module Job
    class << self
      def dump const, *payload
        Marshal.dump([const, *payload])
      end

      def load serialized_payload
        const, *payload = Marshal.load(serialized_payload)
        #[const_name.split("::").inject(Kernel){|res,current| res.const_get(current)}, *payload]
      end
    end
  end
end
