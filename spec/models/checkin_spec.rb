require 'spec_helper'

describe "Checkin Model" do
  before :each do
    @event = FactoryGirl.create(:event)
    @account = FactoryGirl.create(:account)
    @checkin = Checkin.new(:account => @account, :event => @event)
  end

  it 'should require some details to be created' do
    @checkin.should be_valid
    
    @checkin = Checkin.new
    @checkin.should_not be_valid
    @checkin.errors.count.should == 3
    @checkin.errors.on(:account_id).should_not be_nil
    @checkin.errors.on(:event_id).should_not be_nil
  end
  
  it 'should only allow a user to checkin once to an event' do
    @checkin.save
    
    new_checkin = Checkin.new(@checkin.attributes)
    
    new_checkin.should_not be_valid
    new_checkin.errors.on(:account_id).should_not be_nil
  end
  
  it 'should only allow a user to checkin during the event' do
    @event.start_time = Time.now + 1024
    @checkin.should_not be_valid
    @checkin.errors.on(:created_during_event).should_not be_nil

    @event.start_time = Time.now - 1024
    @event.end_time = Time.now - 10
    @checkin.should_not be_valid
    @checkin.errors.on(:created_during_event).should_not be_nil
  end
  
end
