require 'spec_helper'

describe EQ::Queueing::Queue do
  subject do
    FileUtils.rm_rf 'tmp/rspec/queue.leveldb'
    EQ::Queueing::Queue.new EQ::Queueing::Backends::LevelDB.new('tmp/rspec/queue.leveldb')
  end

  it 'instantiates EQ::Job' do
    id = nil
    job_class = AJob
    payload = ['bar', 'baz']
    job = EQ::Job.new(id, job_class, payload)
    EQ::Job.stub(:new).and_return(job)
    EQ::Job.should_receive(:new).with(id, job_class, payload)
    subject.push job_class, *payload
  end
end
