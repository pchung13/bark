migration 6, :create_product_items do
  up do
    create_table :product_items do
      column :id, Integer, :serial => true
      column :product_id, Integer
      column :size, String, :length => 255, :allow_nil => true
      column :cost_price, Integer
      column :sale_id, Integer, :allow_nil => true
      column :price, Integer, :allow_nil => true
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :product_items
  end
end
