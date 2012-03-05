require 'spec_helper'

describe "Event Model" do
  before :each do
    @event = FactoryGirl.build(:event)
    @event.start_time = Time.now + 1024
  end

  it 'should require some details to be created' do
    @event.should be_valid
    
    @event = Event.new
    @event.should_not be_valid
    @event.errors.count.should == 5
    @event.errors.on(:name).should_not be_nil
    @event.errors.on(:start_time).should_not be_nil
    @event.errors.on(:end_time).should_not be_nil
    @event.errors.on(:description).should_not be_nil
  end

  it 'should validate the event ends after it starts' do
    @event.start_time = Time.now + 10000
    @event.should_not be_valid
    @event.errors.on(:dates_are_ordered).should_not be_nil
  end
  
  it 'should get currently running events' do
    event = FactoryGirl.create(:event)
    Event.current.should == [event]
  end
  
end
