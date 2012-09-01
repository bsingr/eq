require 'spec_helper'

describe EQ::Queueing::Queue do
  subject do
    FileUtils.rm_rf 'tmp/rspec/queue.leveldb'
    EQ::Queueing::Queue.new EQ::Queueing::Backends::LevelDB.new('tmp/rspec/queue.leveldb')
  end
  it_behaves_like 'abstract queue'

  it 'instantiates EQ::Job' do
    job = EQ::Job.new(nil, 'foo', ['bar', 'baz'])
    EQ::Job.stub(:new).and_return(job)
    EQ::Job.should_receive(:new).with(job.id, job.queue_str, job.payload)
    subject.push 'foo', 'bar', 'baz'
  end
end
