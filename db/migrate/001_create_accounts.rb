migration 1, :create_accounts do
  up do
    create_table :accounts do
      column :id,               Integer,  :serial => true
      column :student_id,       String,   :length => 255
      column :role,             String,   :length => 255, :default => "user"

      # Optional
      column :rfid,             String,   :length => 255, :allow_nil => true
      column :crypted_password, String,   :length => 255, :allow_nil => true
      column :over_18,          Boolean,  :allow_nil => true

      # Optional from PP
      column :cse_id,   String,   :allow_nil => true
      column :program,  String,   :allow_nil => true
      column :name,     String,   :allow_nil => true
      
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :accounts
  end
end
