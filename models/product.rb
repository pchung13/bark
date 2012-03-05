class Product
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :slug, String, :required => true
  property :price, Integer, :required => true
  property :description, Text, :required => true
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
end
