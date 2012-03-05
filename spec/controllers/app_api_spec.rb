require 'spec_helper'

describe "App Api Controller" do
  before :each do
    ##
    # Create an admin and user account
    #
    FactoryGirl.build(:account, :rfid => "ABCD1234").save
    FactoryGirl.build(:admin).save
    FactoryGirl.create(:event)
    FactoryGirl.create(:event, :start_time => Time.now + 100)
  end
  
  it 'should require a user to be logged in' do
    get '/api/v1/events'
    last_response.status.should == 401
    last_response.body.should == {"error" => "UNAUTHENTICATED"}.to_json
  end
  
  it 'should require the user to be an admin' do
    get '/api/v1/events', {}, "rack.session" => {:user_id => '1'}
    last_response.status.should == 401
    last_response.body.should == {"error" => "UNAUTHORIZED"}.to_json
  end
  
  it 'should get events it is possible to check into' do
    get '/api/v1/events', {}, "rack.session" => {:user_id => '2'}
    last_response.status.should == 200
    event = Event.first
    JSON.parse(last_response.body)["events"].each do |k, v|
      event[k].should == v
    end
  end
  
  describe 'when checking in a user' do    
    it 'should checkin a user with rfid' do
      expect {
        post '/api/v1/checkin', {:event_id => 1, :rfid => "ABCD1234"}, "rack.session" => {:user_id => '2'}
        last_response.status.should == 201
        json = JSON.parse(last_response.body)
        json['status'].should == "CHECKED_IN"
        account = Account.first.attributes
        
        # Compare the keys and values in the json
        json["account"].each do |k, v|
          account[k.to_sym].to_s.should == v.to_s
        end
        
      }.to change {Checkin.all.count}.by(1)
    end
    
    it 'should checkin a user with a student number' do
      expect {
        post '/api/v1/checkin', {:event_id => 1, :student_id => "3000000"}, "rack.session" => {:user_id => '2'}
        last_response.status.should == 201
        json = JSON.parse(last_response.body)
        json['status'].should == "CHECKED_IN"
        account = Account.first.attributes
        
        # Compare the keys and values in the json
        json["account"].each do |k, v|
          account[k.to_sym].to_s.should == v.to_s
        end
      }.to change {Checkin.all.count}.by(1)
    end
    
    it 'should not checkin anyone when neither rfid nor student number is provided' do
      expect {
        post '/api/v1/checkin', {:event_id => 1}, "rack.session" => {:user_id => '2'}
        last_response.status.should == 201
        json = JSON.parse(last_response.body)
        json['status'].should == "NOT_MEMBER"
      }.to_not change {Checkin.all.count}
    end
    
    it 'should provide reasons why a user can not be created' do
      expect {
        post '/api/v1/checkin', {:event_id => 2, :rfid => "ABCD1234"}, "rack.session" => {:user_id => '2'}
        last_response.status.should == 201
        json = JSON.parse(last_response.body)
        json['status'].should == "INVALID"
        json['reason'].should == ["You can only check into an event while the event is running"]
      }.to_not change {Checkin.all.count}
    end
    
    it 'should return if the user is not a memmber' do
      post '/api/v1/checkin', {:event_id => 1, :rfid => "DCBA4321"}, "rack.session" => {:user_id => '2'}
      last_response.status.should == 201
      json = JSON.parse(last_response.body)
      json['status'].should == "NOT_MEMBER"
    end
  end
  
  describe 'when registering a user' do
    it 'should create a new user' do
      expect {
        post '/api/v1/register', {:rfid => "ABCD0000", :student_id => '3900000'}, "rack.session" => {:user_id => '2'}
        last_response.status.should == 201
        json = JSON.parse(last_response.body)
        json['status'].should == "REGISTERED"
      }.to change {Account.all.count}.by(1)
    end
    
    it 'should provide reasons why a user can not be created' do
      expect {
        post '/api/v1/register', {:rfid => "ABCD1234", :student_id => '3900000'}, "rack.session" => {:user_id => '2'}
        last_response.status.should == 201
        json = JSON.parse(last_response.body)
        json['status'].should == "INVALID"
        json['reason'].should == ["Rfid is already taken"]
      }.to_not change {Account.all.count}
    end
  end
  
end
