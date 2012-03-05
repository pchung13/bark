require 'spec_helper'

describe "Auth Api Controller" do
  before :each do
    ##
    # Create an admin and user account
    #
    FactoryGirl.build(:account).save
    FactoryGirl.build(:admin).save
  end
  
  it 'should log in valid admin users' do
    post '/auth/login', :student_id => '3000001', :password => 'password'
    last_response.status.should == 201
    JSON.parse(last_response.body)["status"].should == "LOGGED_IN"
  end
  
  it 'should reject non admin users' do
    post '/auth/login', :student_id => '3000000', :password => 'password'
    last_response.status.should == 403
    JSON.parse(last_response.body)["error"].should == "NOT_ADMIN"
  end
  
  it 'should reject incorrect credentials' do
    post '/auth/login', :student_id => '3000001', :password => 'notpassword'
    last_response.status.should == 403
    JSON.parse(last_response.body)["error"].should == "INVALID"
  end

end
