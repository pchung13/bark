FactoryGirl.define do
  factory :account do
    student_id '3000000'
    role 'user'
    password 'password'
    password_confirmation 'password'
  end
  
  factory :admin, :class => :account do
    student_id '3000001'
    role 'admin'
    password 'password'
    password_confirmation 'password'
  end
  
  factory :event do
    name "Weekly BBQ"
    start_time Time.now - 100
    end_time Time.now + 9048
    description "A weekly BBQ for everyone!"
  end

end