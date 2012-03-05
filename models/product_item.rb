class ProductItem
  include DataMapper::Resource

  property :id, Serial
  property :size, String
  property :cost_price, Integer, :required => true
  property :price, Integer
  
  belongs_to :product, :required => true
  belongs_to :sale
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
end
