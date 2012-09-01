require 'spec_helper'

EQ::Queueing::Backends.require_queue 'sequel'

describe EQ::Queueing::Backends::Sequel do
  subject { EQ::Queueing::Backends::Sequel.new 'sqlite:/' }
  it_behaves_like 'abstract queue'
  it_behaves_like 'queue backend'

  it 'handles ::Sequel::DatabaseError with retry' do
    db_method = subject.instance_eval('method(:jobs)')
    raised = false
    subject.stub(:jobs).and_return do |arg|
      if raised
        db_method.call
      else
        raised = true
        raise ::Sequel::DatabaseError, "failed"
      end
    end
    subject.count(:waiting).should == 0
    subject.push EQ::Job.new(nil, 'foo')
    subject.count(:waiting).should == 1
  end
end
