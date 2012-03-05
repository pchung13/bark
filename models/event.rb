class Event
  include DataMapper::Resource
  include DataMapper::Validate
  include DataMapper::Timestamps
  
  property :id,           Serial
  property :name,         String,       :required => true
  property :start_time,   DateTime,     :required => true
  property :end_time,     DateTime,     :required => true
  property :description,  Text,         :required => true
  
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :checkins
  
  validates_with_method :dates_are_ordered
  
  def self.current
    all(:start_time.lt => Time.now, :end_time.gt => Time.now)
  end
  
  private
  ##
  # Validate the start time is before the end time
  #
  def dates_are_ordered
    if (self.start_time && self.end_time && (self.start_time <= self.end_time))
      true
    else
      [ false, "The event must start before it ends" ]
    end
  end
  
end
