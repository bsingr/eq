require 'spec_helper'

describe EQ do
  context 'transient queueing' do
    it "won't survives at least a dying queue actor" do
      # setup a in-memory queue backend
      EQ.config {|c| c.queue = 'sequel'; c.sequel = 'sqlite:/'}
      EQ.boot
      EQ.queue.push AJob
      EQ.queue.count.should == 1
      EQ.shutdown
      EQ.boot
      EQ.queue.count.should == 0
    end
  end
end
