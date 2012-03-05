shared_examples "an admin controller" do |actions|

  path = actions.delete(:path)
  
  context "an admin user" do
    actions.each_pair do |action, verb|
      specify "should be able to access ##{action} via #{verb}" do
        post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
        send(verb, "#{path}/#{action}")
        last_response.status.should be 200
      end
    end
    
    specify "should edit for an object" do
      post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
      get "#{path}/edit/1"
      last_response.status.should be 200
    end
    
    specify "should update an object" do
      post '/admin/sessions/create', :student_id => @admin.student_id, :password => 'password'
      post "#{path}/update/1"
      last_response.status.should be 405
    end
  end

  context "a regular user" do
    actions.each_pair do |action, verb|
      specify "should be denied access to ##{action}" do
        delete '/admin/sessions/destroy'
        send(verb, "#{path}/#{action}")
        last_response.status.should be 302
      end
    end
  end
end
