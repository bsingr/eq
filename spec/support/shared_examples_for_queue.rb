shared_examples_for 'queue backend' do
  let(:eq_job) { EQ::Job.new(nil, AJob, 'foo') }

  it 'has no jobs at the beginning' do
    subject.count(:jobs).should == 0
    subject.count(:waiting).should == 0
    subject.count(:working).should == 0
  end

  it 'pushes jobs' do
    subject.push(eq_job).should_not be_nil # job_id
    subject.count(:jobs).should == 1
    subject.count(:waiting).should == 1
    subject.count(:working).should == 0
  end

  it 'reserves jobs' do
    id = subject.push eq_job
    subject.count(:jobs).should == 1
    subject.count(:waiting).should == 1
    subject.count(:working).should == 0
    job = subject.reserve
    id.should == job.id
    subject.count(:jobs).should == 1
    subject.count(:waiting).should == 0
    subject.count(:working).should == 1
  end

  it 'pops jobs' do
    subject.pop(1).should be_false # no job
    job_id = subject.push eq_job
    subject.count(:jobs).should == 1
    subject.count(:waiting).should == 1
    subject.count(:working).should == 0
    subject.pop(job_id).should be_true # one job
    subject.count(:jobs).should == 0
    subject.count(:waiting).should == 0
    subject.count(:working).should == 0
    subject.pop(1).should be_false # again no job"
  end

  it 'clears jobs' do
    10.times { subject.push(eq_job) }
    subject.count.should == 10
    subject.clear
    subject.count.should == 0
  end

  it 'puts working job back on waiting when they timeout via #requeue_timed_out_jobs' do
    # freeze time on start of 1986
    Timecop.freeze(Time.new(1986)) do
    
      # create a job
      id = subject.push eq_job

      # start working
      data = subject.reserve

      # no on working at the beginning
      subject.count(:waiting).should == 0
      subject.count(:working).should == 1

      # no one will be re-enqueued
      subject.requeue_timed_out_jobs.should == 0

      # no on working after senseless re-enqueueing
      subject.count(:waiting).should == 0
      subject.count(:working).should == 1
    end

    # freeze the time to 10s in the future
    Timecop.freeze(Time.new(1986, 01, 01, 00, 00, EQ.config.job_timeout)) do  
      
      # nothing happened yet...
      subject.count(:waiting).should == 0
      subject.count(:working).should == 1

      # this time one will be re-enqueued
      subject.requeue_timed_out_jobs.should == 1
    
      # now the old job is available again
      subject.count(:waiting).should == 1
      subject.count(:working).should == 0
    end
  end

  context 'unique jobs' do
    it 'does not enqueue multiple times when args are the same' do
      subject.count.should == 0
      id = subject.push EQ::Job.new(nil, AUniqueJob)
      subject.count.should == 1
      id = subject.push EQ::Job.new(nil, AUniqueJob)
      subject.count.should == 1
    end

    it 'does enqueue multiple times when args differ' do
      subject.count.should == 0
      id = subject.push EQ::Job.new(nil, AUniqueJob, 'foo')
      subject.count.should == 1
      id = subject.push EQ::Job.new(nil, AUniqueJob, 'bar')
      subject.count.should == 2
    end
  end
end
