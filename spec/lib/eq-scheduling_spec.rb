require 'spec_helper'

describe EQ::Scheduling do
  it 'list of events is empty per default' do
    EQ::Scheduling.events.should == []
  end
end
