require 'spec_helper'

describe EQ::Job do |variable|
  it 'dumps const and payload' do
    payload = EQ::Job.dump(EQ, 'bar', 'baz')
    Marshal.load(payload).should == [EQ, 'bar', 'baz']
  end

  it 'loads const and payload' do
    payload = Marshal.dump [EQ, 'foo', 'bar']
    EQ::Job.load(payload).should == [EQ, 'foo', 'bar']
  end
end
