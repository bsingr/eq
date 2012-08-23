require 'spec_helper'

describe EQ::Queueing::Backends::SortedSet do
  subject { EQ::Queueing::Backends::SortedSet.new }
  it_behaves_like 'abstract queue'
  it_behaves_like 'queue backend'
end
