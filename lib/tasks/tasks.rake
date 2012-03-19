task :refresh_cse_data => :environment do
  if ENV["CSENATRA_ON"] != 'yes'
    # Check that CSENATRA is configured and on
    raise "CSENATRA_NOT_ON"
  end
  
  accounts = Account.all
  accounts.each do |a|
    not_done = true
    while not_done
      begin
        # Make cse_id dirty
        a.fill_cse_details
        a.save
        not_done = false
      rescue JSON::JSONError => ex
        puts "Auth Error, silly CSE. Lets try again!"
      end
    end
    puts "Done Account: #{a.cse_id}"
  end
end
