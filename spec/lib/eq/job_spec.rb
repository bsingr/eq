require 'spec_helper'

describe EQ::Job do |variable|
  it 'dumps const and payload' do
    payload = EQ::Job.dump(EQ, 'bar', 'baz')
    Marshal.load(payload).should == [EQ, 'bar', 'baz']
  end

  it 'loads const and payload' do
    serialized_payload = Marshal.dump [EQ, 'foo', 'bar']
    job = EQ::Job.load(1, serialized_payload)
    job.unpack.should == [EQ, 'foo', 'bar']
  end

  it 'performs using const.perform(*payload)' do
    class MyJob
      def self.perform(*args)
        {result: args}
      end
    end
    my_job_args = [1,2,3]
    serialized_payload = EQ::Job.dump(MyJob, *my_job_args)
    job = EQ::Job.load(1, serialized_payload)
    job.perform.should == {result: my_job_args}
  end
end
