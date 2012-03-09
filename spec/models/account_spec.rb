require 'spec_helper'

describe "Account Model" do
  before :each do
    @account = FactoryGirl.build(:account)
  end

  it 'should require some details to be created' do
    @account.should be_valid
    
    @account = Account.new
    @account.should_not be_valid
    @account.errors.count.should == 5
    @account.errors.on(:student_id).count.should == 2
    @account.errors.on(:role).should_not be_nil
    @account.errors.on(:password).count.should == 2
    @account.errors.on(:password_confirmation).should_not be_nil
  end
  
  it 'should require a valid student id' do
    @account.student_id = 'wordsas'
    @account.should_not be_valid
    @account.errors.on(:student_id).count.should == 1
    @account.errors.on(:student_id).include?("Student has an invalid format").should == true
        
    @account.student_id = '300'
    @account.should_not be_valid
    @account.errors.on(:student_id).count.should == 1
    @account.errors.on(:student_id).include?("Student must be between 7 and 7 characters long").should == true
  end
  
  it 'should only allow one record for each student id' do
    @account.student_id = '3000001'
    @account.save.should be_true
    attributes = @account.attributes
    @account.id = nil
    
    @account = Account.new(attributes)
    @account.student_id = '3000001'
    @account.save.should be_false
    @account.errors.on(:student_id).should_not be_nil
  end
  
  it 'should only allow one record for each rfid' do
    @account.rfid = "ABCD1234"
    @account.save.should be_true
    attributes = @account.attributes
    @account.id = nil
    
    @account = Account.new(attributes)
    @account.rfid = "ABCD1234"
    @account.save.should be_false
    @account.errors.on(:rfid).should_not be_nil
  end
  
  it 'should only allow one record for each cse id regardless of case' do
    @account.cse_id = 'name'
    @account.save.should be_true
    attributes = @account.attributes
    @account.id = nil
    
    @account = Account.new(attributes)
    @account.cse_id = 'Name'
    @account.save.should be_false
    @account.errors.on(:cse_id).should_not be_nil
  end
  
  it 'should provide an email' do
    stub_request(:get, "http://csenatrausername:csenatrapassword@exmaple.com/~username/api/remote?user=3000000").
       to_return(:status => 200, :body => {'user' => "username", 'name' => "Myname Surname", 'program' => "3000"}.to_json)
    
    @account.email.should == "z3000000@student.unsw.edu.au"
    @account.fill_cse_details
    @account.email.should == "username@cse.unsw.edu.au"
  end
  
  it 'should require a valid password' do
    @account.password = 'asd'
    @account.should_not be_valid
    @account.errors.on(:password).should_not be_nil
  end
  
  it 'should require a valid role' do
    @account.role = 'cool person'
    @account.should_not be_valid
    @account.errors.on(:valid_role).should_not be_nil
  end
  
  it 'should lookup the cse details of a user' do
    stub_request(:get, "http://csenatrausername:csenatrapassword@exmaple.com/~username/api/remote?user=3000000").
       to_return(:status => 200, :body => {'user' => "username", 'name' => "Myname Surname", 'program' => "3000"}.to_json)
    
    @account.fill_cse_details
    @account.cse_id.should   == 'username'
    @account.program.should  == '3000'
    @account.name.should     == 'Myname Surname'
  end
  
  it 'should lookup non cse program students who are in cse' do
    stub_request(:get, "http://csenatrausername:csenatrapassword@exmaple.com/~username/api/remote?user=3000000").
       to_return(:status => 200, :body => {'user' => "notmember", 'name' => "Someones Name", 'program' => "NONCSE"}.to_json)
    
    @account.fill_cse_details
    @account.cse_id.should   == 'notmember'
    @account.program.should  == 'NONCSE'
    @account.name.should     == 'Someones Name'
  end
  
  it 'should report if a student does not have a cse @account' do
    stub_request(:get, "http://csenatrausername:csenatrapassword@exmaple.com/~username/api/remote?user=3000000").
       to_return(:status => 200, :body => {}.to_json)
    
    @account.fill_cse_details
    @account.cse_id.should be_nil
    @account.program.should be_nil
    @account.name.should be_nil
  end
  
  it 'should find a user by id' do
    @account.save
    id = @account.id
    
    Account.find_by_id(id).should == @account
    Account.find_by_id(-1).should == nil
  end
  
  it 'should authenticate a user' do
    @account.save
    
    Account.authenticate('3000000', 'password').should == @account
    Account.authenticate('3000001', 'password').should == nil
    Account.authenticate('3000000', 'pass1234').should == nil   
  end
  
  it 'should have many checkins' do
    @account.save
    checkin = @account.checkins.create(:event => FactoryGirl.create(:event))
    @account.checkins.should == [checkin]
  end
  
  it 'should have attendence at many events' do
    @account.save
    event = FactoryGirl.create(:event)
    checkin = @account.checkins.create(:event => event)
    @account.attended_events.should == [event]
  end
  
  describe 'create_from_json' do
    ##
    # The structure of the JSON file should be
    #   [ { "rfid":"1234512345",
    #       "student_id":"3001234",
    #       "checkins":[1,2]
    #     }, 
    #     { "rfid":"12345aaaaa",
    #       "student_id":"3004321",
    #       "checkins":[1] }
    #   ]
    before do
      FactoryGirl.create(:event)
      FactoryGirl.create(:event)
      @account.save
    end
    
    it 'should create new accounts for unregistered users without rfid' do
      user = {'student_id' => '3001234', 'checkins' => [1, 2]}
      expect {
        Account.create_from_json(user)
      }.to change{Account.count}.by(1)
      
      new_account = Account.last
      new_account.student_id.should == '3001234'
      new_account.rfid.should == nil
      new_account.checkins.map {|x| x.id}.should == [1, 2]
    end
    
    it 'should create new accounts for unregistered users with rfid' do
      user = {'rfid' => "1234512345", 'student_id' => '3001234', 'checkins' => [1, 2]}
      expect {
        Account.create_from_json(user)
      }.to change{Account.count}.by(1)
      
      new_account = Account.last
      new_account.student_id.should == '3001234'
      new_account.rfid.should == '1234512345'
      new_account.checkins.map {|x| x.id}.should == [1, 2]
    end
    
    it 'should update the rfid of existing accounts' do
      account = Account.first
      user = {'rfid' => "1234512345", 'student_id' => account.student_id, 'checkins' => [1, 2]}
      expect {
        Account.create_from_json(user)
      }.to_not change {Account.count}
      
      account = Account.first
      account.rfid.should == "1234512345"
      account.checkins.map {|x| x.id}.should == [1, 2]
    end
    
    it 'should be somewhat robust to invalid entry' do
      user = {'rfid' => "1234512345", 'student_id' => '0', 'checkins' => [1, 2]}
      expect {
        Account.create_from_json(user)
      }.to raise_error("Unable To Save Account")
      
      user = {'rfid' => "1234512345", 'student_id' => '3001234', 'checkins' => [3]}
      expect {
        Account.create_from_json(user)
      }.to raise_error("Event Not Found: 3")
    end
  end
  
end
