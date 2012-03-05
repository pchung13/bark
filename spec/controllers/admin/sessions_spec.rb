require 'spec_helper'

describe "Admin Sessions Controller" do
  before :each do
    ##
    # Create an admin and user account
    #
    FactoryGirl.build(:account, :rfid => "ABCD1234").save
    @admin = FactoryGirl.build(:admin)
    @admin.save
    FactoryGirl.create(:event)
    FactoryGirl.create(:event, :start_time => Time.now + 100)
  end
  
  it 'should prompt the user to login' do
    get '/admin/sessions/new'
    last_response.status.should == 200
  end
  
  it 'should log in valid users' do
    post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
    last_response.status.should == 302
    last_response.headers["location"].should_not include("/admin/sessions")
  end
  
  it 'should reject invalid logins' do
    post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'passwrong'
    last_response.status.should == 302
    last_response.headers["location"].should include("/admin/sessions/new")
  end
  
  it 'should logout users' do
    delete '/admin/sessions/destroy'
    last_response.status.should == 302
    last_response.headers["location"].should include("/admin/sessions/new")
  end
  
end
