require 'spec_helper'

describe EQ::Queueing::Queue do
  subject { EQ::Queueing::Queue.new(EQ::Queueing::Backends::SortedSet.new) }
  it_behaves_like 'abstract queue'

  it 'serializes jobs' do
    EQ::Job.should_receive(:dump).with(["foo"])
    subject.push "foo"
  end

  it 'deserializes jobs' do
    subject.push "foo"
    EQ::Job.should_receive(:load).with(1, EQ::Job.dump(["foo"]))
    subject.reserve
  end
end
