migration 3, :create_checkins do
  up do
    create_table :checkins do
      column :id, Integer, :serial => true
      column :account_id, Integer
      column :event_id, Integer
      
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :checkins
  end
end
