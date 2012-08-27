require 'spec_helper'

describe EQ::Queueing::Queue do
  subject do
    FileUtils.rm_rf 'tmp/rspec/queue.leveldb'
    EQ::Queueing::Queue.new EQ::Queueing::Backends::LevelDB.new('tmp/rspec/queue.leveldb')
  end
  it_behaves_like 'abstract queue'

  it 'serializes jobs' do
    EQ::Job.should_receive(:dump).with(["foo"]).and_return(Marshal.dump(["foo"]))
    subject.push "foo"
  end

  it 'deserializes jobs' do
    job_id = subject.push "foo"
    EQ::Job.should_receive(:load).with(job_id, Marshal.dump(["foo"]))
    subject.reserve
  end
end
