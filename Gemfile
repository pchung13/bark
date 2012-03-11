source :rubygems

# Server requirements (defaults to WEBrick)
# gem 'thin'
# gem 'mongrel'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'rack-less', :require => 'rack/less'
gem 'erubis', "~> 2.7.0"

group :development do
  gem 'dm-sqlite-adapter'
end

group :production do
  gem 'dm-postgres-adapter'
  gem "rack-ssl-enforcer", :require => "rack/ssl-enforcer"
end

gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations'
gem 'dm-constraints'
gem 'dm-aggregates'
gem 'dm-transactions'
gem 'dm-core'
gem 'dm-serializer', '1.2.1'

# Test requirements
group :test do
  gem 'mocha'
  gem 'rspec'
  gem 'rack-test', :require => "rack/test"
  gem 'webmock', :require => "webmock/rspec"
  gem 'simplecov', :require => false
  gem 'database_cleaner'
  gem "factory_girl", "~> 2.1.0"
end

# Padrino Stable Gem
gem 'padrino', '0.10.5'

# App requirements
gem "grape", :git => "git://github.com/intridea/grape.git"
gem "dalli", :git => "git://github.com/mperham/dalli.git", :require => 'rack/session/dalli'
gem "faraday"
gem "json"

# Or Padrino Edge
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.10.5'
# end
