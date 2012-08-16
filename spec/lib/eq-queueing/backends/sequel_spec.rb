require 'spec_helper'

describe EQ::Queueing::Backends::Sequel do
  subject { EQ::Queueing::Backends::Sequel.new }
  it_behaves_like 'abstract queue'
  it_behaves_like 'queue backend'
end
