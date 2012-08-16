shared_examples_for 'queue backend' do
  it 'pushes and pops' do
    subject.push "foo"
    job_id, payload = *subject.reserve
    job_id.should == 1
    payload.should == "foo"
  end
end

shared_examples_for 'abstract queue' do
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
