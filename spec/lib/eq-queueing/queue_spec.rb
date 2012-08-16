require 'spec_helper'

describe EQ::Queueing::Queue do
  let(:queue_backend) do
    Class.new(Struct.new(:waiting, :working)) do
      def push payload
        raise ArgumentError, "queue_backend mock only supports one waiting job at a time" if waiting
        self.waiting = [1, payload]
      end

      def reserve
        raise ArgumentError, "queue_backend mock only supports one working job at a time" if working
        if self.working = waiting
          self.waiting = nil
          return working
        end
      end

      def pop id
        raise ArgumentError, "no working job" if !working
        self.working = nil
      end

      def waiting_count; waiting ? 1 : 0; end
      def working_count; working ? 1 : 0; end
    end.new
  end
  subject { EQ::Queueing::Queue.new(queue_backend) }
  it_behaves_like 'queue'

  it 'serializes jobs' do
    EQ::Job.should_receive(:dump).with(["foo"])
    subject.push "foo"
  end

  it 'deserializes jobs' do
    subject.push "foo"
    EQ::Job.should_receive(:load).with(1, [EQ::Job.dump(["foo"])])
    subject.reserve
  end
end
