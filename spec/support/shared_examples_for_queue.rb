shared_examples_for 'queue backend' do
  it 'pushes and pops' do
    subject.push Marshal.dump ['foo','bar']
    job_id, serialized_payload = *subject.reserve
    Marshal.load(serialized_payload).should == ['foo', 'bar']
  end
end

shared_examples_for 'queue' do
  it 'pushes jobs' do
    subject.waiting_count.should == 0
    subject.working_count.should == 0
    subject.push "foo"
    subject.waiting_count.should == 1
    subject.working_count.should == 0
  end

  it 'reserves jobs' do
    subject.push "foo"
    id = subject.reserve
    subject.waiting_count.should == 0
    subject.working_count.should == 1
    subject.pop id
    subject.waiting_count.should == 0
    subject.working_count.should == 0
  end
end
