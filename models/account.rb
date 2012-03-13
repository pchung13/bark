class Account
  ##
  # Account Model
  # 
  # Required fields
  # - student_id
  # - password
  # - *role*, but it is automatically set
  # 
  # Optional Fields
  # - *password* is only required if it has been set. Otherwise it is nil.
  #
  
  include DataMapper::Resource
  include DataMapper::Validate
  include DataMapper::Timestamps
  attr_accessor :password, :password_confirmation
  ROLES = ["user", "admin"]
  
  ##
  # Required
  #
  property :id,               Serial
  property :student_id,       String, :required => true, :unique => true
  property :role,             String, :required => true
  property :crypted_password, String, :length => 70
    
  ##
  # Optional
  #
  property :rfid,             String
  property :over_18,          Boolean

  ##
  # Optional from PP
  #
  property :cse_id,  String
  property :program, String
  property :name,    String

  ##
  # Timestamps
  #
  property :created_at, DateTime
  property :updated_at, DateTime
  
  ##
  # Relations
  #
  has n, :checkins
  has n, :attended_events, Event, :through => :checkins, :via => :event

  ##
  # Validations
  #
  validates_length_of :student_id, :min => 7, :max => 7
  validates_format_of :student_id, :with => /^\d*$/
  
  validates_uniqueness_of :rfid,    :if => lambda { |t| t.rfid.present? }
  
  validates_with_method :lowercase_cse_id # This must be before uniqueness
  validates_uniqueness_of :cse_id,  :if => lambda { |t| t.cse_id.present? }
  
  validates_presence_of :password,              :if => :password_required
  validates_presence_of :password_confirmation, :if => :password_required
  validates_length_of       :password,          :if => :password_required, :min => 4, :max => 40
  validates_confirmation_of :password,          :if => :password_required
  validates_with_method :valid_role
  
  ##
  # Callbacks
  #
  before :save, :encrypt_password
  
  ##
  # The student's email
  # 
  def email
    if self.cse_id.nil?
      "z#{student_id}@student.unsw.edu.au"
    else
      "#{cse_id}@cse.unsw.edu.au"
    end
  end

  ##
  # This method is for authentication purpose
  #
  def self.authenticate(student_id, password)
    account = first(:conditions => { :student_id => student_id }) if student_id.present?
    account && account.has_password?(password) ? account : nil
  end

  ##
  # This method is used by AuthenticationHelper
  #
  def self.find_by_id(id)
    get(id) rescue nil
  end

  ##
  # Checks if the given password is valid
  #
  def has_password?(password)
    ::BCrypt::Password.new(self.crypted_password) == password
  end
  
  ##
  # Fill's in the user's details from CSE
  #  
  def fill_cse_details
    conn = Faraday.new(:url => 'https://cgi.cse.unsw.edu.au') do |builder|
      builder.request  :url_encoded
      builder.adapter  :net_http
    end
    
    conn.basic_auth ENV["CSENATRA_USERNAME"], ENV["CSENATRA_PASSWORD"]
    data = conn.get do |req|
      req.url ENV["CSENATRA_URL"] # "/~username/api/remote"
      req.params['user'] = self.student_id
    end.body
    data = JSON.parse data
    
    self.cse_id   = data["user"]
    self.name     = data["name"]
    self.program  = data["program"]
  end
  
  ##
  # Creates a new account from a json hash
  #
  def self.create_from_json(user)
    account = Account.first(:student_id => user["student_id"])
    if account
      # User already registered with student number
      # Set their RFID
      account.rfid = user["rfid"]
    else
      # Account doesn't exist, create a new one
      account = Account.new(:student_id => user["student_id"], :rfid => user["rfid"])
      account.role = 'user'
      password = SecureRandom.hex(16)
      account.password = password
      account.password_confirmation = password
    end
    raise "Unable To Save Account" unless account.save
    
    # Create any checkins for this user
    user["checkins"].each do |event_id|
      raise "Event Not Found: #{event_id}" unless Event.get(event_id)
      Checkin.create!(:account => account, :event_id => event_id)
    end
  end
  
  private
  
  ##
  # Validates the role is a valid choice
  # 
  def valid_role
    if ROLES.include?(self.role)
      true
    else
      [false, "The account has an invalid role"]
    end
  end
  
  ##
  # Determine if a password is requried
  #
  def password_required
    self.crypted_password.blank? || self.password.present?
  end

  ##
  # Convert the CSE ID to lower case
  #
  def lowercase_cse_id
    self.cse_id = self.cse_id.downcase if self.cse_id.present?
    true
  end

  ##
  # Encrypts the user's password
  #
  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(self.password) if self.password.present?
    
    if ENV["CSENATRA_ON"] == 'yes'
      # If CSEnatra is on
      self.fill_cse_details
    end
  end
end
