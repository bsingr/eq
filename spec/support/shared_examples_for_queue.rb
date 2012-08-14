shared_examples_for 'queue' do
  it 'pushes and pops' do
    subject.push Marshal.dump ['foo','bar']
    Marshal.load(subject.pop).should == ['foo', 'bar']
  end
end
