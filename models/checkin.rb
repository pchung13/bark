class Checkin
  include DataMapper::Resource
  include DataMapper::Validate
  include DataMapper::Timestamps
  
  property :id, Serial
  belongs_to :account, :required => true
  belongs_to :event,   :required => true
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  validates_uniqueness_of :account_id, :scope => [:event_id],
    :message => "This user is already checked into this event."

  validates_with_method :created_during_event
  
  private
  ##
  # Validate the checkin is during the Event
  #
  def created_during_event
    if (self.event && self.event.start_time && self.event.end_time) && 
        (self.event.start_time <= DateTime.now) && (self.event.end_time >= DateTime.now)
      true
    else
      [ false, "You can only check into an event while the event is running" ]
    end
  end

end
