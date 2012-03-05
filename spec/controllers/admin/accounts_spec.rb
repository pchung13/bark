require 'spec_helper'
require './spec/controllers/admin/admin_examples'

describe "Admin Accounts Controller" do
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
    :path   => "/admin/accounts",
    '/'     => :get,
    :new    => :get,
    :create => :post
  }
  

  it 'should create new accounts' do
    expect {
      post '/admin/accounts/create', :account => FactoryGirl.attributes_for(:account, :student_id => "3009876")
      last_response.status.should be 302
      last_response.headers["Location"].should == "http://example.org/admin/accounts/edit/3"
    }.to change {Account.all.count}.by(1)
  end
  
  it 'should show problems with creating new accounts' do
    expect {
      post '/admin/accounts/create', :account => FactoryGirl.attributes_for(:account, :student_id => nil)
      last_response.status.should be 200
      last_response.body.should include("Student must not be blank")
    }.to_not change {Account.all.count}
  end
  
  it 'should update accounts' do
    put '/admin/accounts/update/2', :account => {:student_id => "3001234"}
    last_response.status.should be 302
    last_response.headers["Location"].should == "http://example.org/admin/accounts/edit/2"
    Account.last.student_id.should == "3001234"
  end
  
  it 'should show problems with updating accounts' do
    put '/admin/accounts/update/2', :account => {:student_id => nil}
    last_response.status.should be 200
    last_response.body.should include("Student must not be blank")
  end
  
  it 'should delete an account' do
    expect {
      delete '/admin/accounts/destroy/1'
      last_response.status.should be 302
      last_response.headers["Location"].should == "http://example.org/admin/accounts"
    }.to change {Account.all.count}.by(-1)
  end
  
  it 'should may refuse to delete an account' do
    expect {
      # Can't delete your current logged in account
      # So use ID 2, which is the current logged in user
      delete '/admin/accounts/destroy/2'
      last_response.status.should be 302
      last_response.headers["Location"].should == "http://example.org/admin/accounts"
    }.to change {Account.all.count}.by(0)
  end
  
end
