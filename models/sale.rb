class Sale
  include DataMapper::Resource

  property :id, Serial
  property :total_price, Integer, :required => true
  property :user_id, Integer, :required => true
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
end
