require 'spec_helper'

describe EQ::Queueing::Backends::LevelDB do
  subject do
    FileUtils.rm_rf 'tmp/rspec/queue.leveldb'
    EQ::Queueing::Backends::LevelDB.new 'tmp/rspec/queue.leveldb'
  end
  it_behaves_like 'abstract queue'
  it_behaves_like 'queue backend'

  it 'persists created_at correctly' do
    job_id = nil
    created_at = Time.new(1986, 01, 01, 00, 00)
    Timecop.freeze(created_at) do  
      job_id = subject.push 'foo'
    end
    subject.jobs.find_created_at(job_id).should == created_at
  end

  it 'persists started_working_at correctly' do
    job_id = nil
    Timecop.freeze(Time.new(1986, 01, 01, 00, 00, 0)) do
      job_id = subject.push 'foo'
    end
    started_working_at = Time.new(1986, 01, 01, 00, 01)
    Timecop.freeze(started_working_at) do
      subject.reserve
    end
    subject.jobs.find_started_working_at(job_id).should == started_working_at
  end
end
