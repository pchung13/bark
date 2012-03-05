migration 7, :create_sales do
  up do
    create_table :sales do
      column :id, Integer, :serial => true
      column :total_price, Integer
      column :user_id, Integer, :allow_nil => true
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :sales
  end
end
