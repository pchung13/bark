migration 5, :create_products do
  up do
    create_table :products do
      column :id, Integer, :serial => true
      column :name, String, :length => 255
      column :slug, String, :length => 255
      column :price, Integer
      column :description, Text
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :products
  end
end
