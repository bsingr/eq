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
    subject.push("foo").should == 1 # job id
    subject.waiting_count.should == 1
    subject.working_count.should == 0
  end

  it 'reserves jobs' do
    id = subject.push "foo"
    subject.reserve
    subject.waiting_count.should == 0
    subject.working_count.should == 1
    subject.pop id
    subject.waiting_count.should == 0
    subject.working_count.should == 0
  end

  it 'pops jobs' do
    subject.pop(1).should be_false # no job
    subject.push "foo"
    subject.pop(1).should be_true # one job
    subject.pop(1).should be_false # again no job"
  end

  it 'puts working job back on waiting when they timeout via #requeue_timed_out_jobs' do
    # freeze time on start of 1986
    Timecop.freeze(Time.new(1986)) do
    
      # create a job
      id = subject.push "foo"

      # start working
      data = subject.reserve

      # no on working at the beginning
      subject.waiting_count.should == 0
      subject.working_count.should == 1

      # no one will be re-enqueued
      subject.requeue_timed_out_jobs.should == 0

      # no on working after senseless re-enqueueing
      subject.waiting_count.should == 0
      subject.working_count.should == 1

    end

    # freeze the time to 10s in the future
    Timecop.freeze(Time.new(1986, 01, 01, 00, 00, EQ.config.job_timeout)) do  
      
      # nothing happened yet...
      subject.waiting_count.should == 0
      subject.working_count.should == 1

      # this time one will be re-enqueued
      subject.requeue_timed_out_jobs.should == 1
    
      # now the old job is available again
      subject.waiting_count.should == 1
      subject.working_count.should == 0

    end
  end
end
