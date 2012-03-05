##
# The rack app that is responsible for authentication
#
class AuthApi < Grape::API
  helpers do
    def session
      env['rack.session'] ||= {}
    end
  end
  
  ##
  # Uses session based cookies to log users in
  # If you have a session based HTTP client, nothing needs
  # to be done for auth to work. Otherwise, implement
  # session based cookies manually.
  #
  post '/login' do
    if account = Account.authenticate(params[:student_id], params[:password])
      if account.role == 'admin'
        session[:user_id] = account.id
        {:status => "LOGGED_IN"}
      else
        error!({ "error" => "NOT_ADMIN" }, 403)
      end
    else
      error!({ "error" => "INVALID" }, 403)
    end
  end
end

##
# The rack app that gives you an API to checkins
# Every call is before filtered by authentication and
# authorization.
#
class AppApi < Grape::API
  version 'v1', :using => :path, :vendor => 'bark', :format => :json
  
  helpers do
    def session
      env['rack.session'] ||= {}
    end
  end
  
  before do
    # Check the user has a valid token
    unless session[:user_id]
      error!({"error" => "UNAUTHENTICATED"}, 401)
    else
      @account = Account.get(session[:user_id])
      unless @account.role == "admin"
        error!({"error" => "UNAUTHORIZED"}, 401)
      end
    end
  end
  
  ##
  # Gives you all the currently available events you can check into
  # Usually one
  #
  get '/events' do
    {:events => Event.current}
  end
  
  ##
  # A checkin to an event
  # Requires an `event_id` as well as either:
  # - rfid
  # - student_id
  #
  # Will respond with either the user who has been checked in
  # or reasons why the checkin couldn't be made.
  # If they are not a member, NOT_MEMBER is given and
  # a member can be made with the `/register` request.
  #
  post '/checkin' do
    event = Event.get(params[:event_id].to_i)
    account = if params[:rfid]
      Account.first(:rfid => params[:rfid])
    elsif params[:student_id]
      Account.first(:student_id => params[:student_id])
    else
      nil
    end
    
    if account
      # Create user checkin
      checkin = event.checkins.new(:account => account)
      if checkin.save
        {:status => "CHECKED_IN", :account => account}
      else
        # unable to checkin
        {:status => "INVALID", :reason => checkin.errors.full_messages}
      end      
    else
      # No user
      {:status => "NOT_MEMBER"}
    end
  end
  
  ##
  # To register a new user
  # Requires:
  # - rfid
  # - student_id
  #
  post '/register' do
    password = SecureRandom.hex(16)
    account = Account.new(:rfid => params[:rfid], :student_id => params[:student_id],
      :role => "user",
      :password => password,
      :password_confirmation => password)
    if account.save
      {:status => "REGISTERED"}
    else
      {:status => "INVALID", :reason => account.errors.full_messages}
    end
  end
end
