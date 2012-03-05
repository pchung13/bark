require 'spec_helper'
require './spec/controllers/admin/admin_examples'

describe "Admin Events Controller" do
  before :each do
    ##
    # Create an admin and user account
    #
    FactoryGirl.build(:account, :rfid => "ABCD1234").save
    @admin = FactoryGirl.build(:admin)
    @admin.save
    FactoryGirl.create(:event)
    FactoryGirl.create(:event, :start_time => Time.now + 100)
    post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
  end
  
  it_behaves_like "an admin controller", {
    :path   => "/admin/events",
    '/'     => :get,
    :new    => :get,
    :create => :post
  }

  it 'should create new events' do
    expect {
      post '/admin/events/create', :event => FactoryGirl.attributes_for(:event)
      last_response.status.should be 302
      last_response.headers["Location"].should == "http://example.org/admin/events/edit/3"
    }.to change {Event.all.count}.by(1)
  end
  
  it 'should show problems with creating new events' do
    expect {
      post '/admin/events/create', :event => FactoryGirl.attributes_for(:event, :name => nil)
      last_response.status.should be 200
      last_response.body.should include("Name must not be blank")
    }.to_not change {Event.all.count}
  end
  
  it 'should update events' do
    put '/admin/events/update/2', :event => {:name => "new_name"}
    last_response.status.should be 302
    last_response.headers["Location"].should == "http://example.org/admin/events/edit/2"
    Event.last.name.should == "new_name"
  end
  
  it 'should show problems with updating events' do
    put '/admin/events/update/2', :event => {:name => nil}
    last_response.status.should be 200
    last_response.body.should include("Name must not be blank")
  end
  
  it 'should delete an event' do
    expect {
      delete '/admin/events/destroy/2'
      last_response.status.should be 302
      last_response.headers["Location"].should == "http://example.org/admin/events"
    }.to change {Event.all.count}.by(-1)
  end
  
  it 'should may refuse to delete an event' do
    expect {
      # Case where the ID isn't available
      delete '/admin/events/destroy/9001'
      last_response.status.should be 302
      last_response.headers["Location"].should == "http://example.org/admin/events"
    }.to change {Event.all.count}.by(0)
  end
  
end
