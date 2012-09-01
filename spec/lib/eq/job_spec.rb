require 'spec_helper'

describe EQ::Job do

  it 'creates a job with payload' do
    job = EQ::Job.new nil, EQ::Job, ['bar', 'foo']
    job.id.should == nil
    job.queue.should == "EQ::Job"
    job.job_class.should == EQ::Job
    job.payload.should == ['bar', 'foo']
  end

  it 'creates a job without payload' do
    job = EQ::Job.new nil, EQ::Job
    job.id.should == nil
    job.queue.should == "EQ::Job"
    job.job_class.should == EQ::Job
    job.payload.should == nil
  end

  it 'performs using queue.perform(*payload)' do
    class MyJob
      def self.perform(*args)
        {result: args}
      end
    end
    my_job_args = [1,2,3]
    job = EQ::Job.new(nil, MyJob, my_job_args)
    job.perform.should == {result: my_job_args}
  end
end
