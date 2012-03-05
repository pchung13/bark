migration 2, :create_events do
  up do
    create_table :events do
      column :id, Integer, :serial => true
      column :name, String, :length => 255
      column :start_time, DateTime
      column :end_time, DateTime
      column :description, Text
      
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :events
  end
end
