require 'spec_helper'

describe "Admin Base Controller" do
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
  
  it 'should require a user to be logged in' do
    get '/admin'
    last_response.status.should == 302
    last_response.headers["location"].should include("/admin/sessions/new")
  end
  
  it 'should show the home page' do
    post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
    get '/admin'
    last_response.status.should == 200
  end
  
  it 'should show the upload page' do
    post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
    get '/admin/base/upload'
    last_response.status.should == 200
  end
  
  it 'should import an upload' do
    expect {
      post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
      file = Rack::Test::UploadedFile.new('./spec/fixtures/import.json', "application/text")
      post "/admin/base/import", :event => {:upload => file }
    }.to change {Account.all.count}.by(2)
    last_response.status.should == 302
  end
  
end
