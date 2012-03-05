PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/config/"
  add_group "Models", "models"
  add_group "API", "api"
  add_group "App", "app"
  add_group "Admin", "admin"
end

require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

ENV["CSENATRA_USERNAME"] = 'csenatrausername'
ENV["CSENATRA_PASSWORD"] = 'csenatrapassword'
ENV["CSENATRA_URL"] = 'http://exmaple.com/~username/api/remote'

FactoryGirl.definition_file_paths = [ File.join(Padrino.root, 'spec', 'factories') ]
FactoryGirl.find_definitions

RSpec.configure do |conf|
  conf.mock_with :mocha
  conf.include Rack::Test::Methods
  conf.include FactoryGirl::Syntax::Methods

  conf.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  conf.before(:each) do
    DatabaseCleaner.start
  end

  conf.after(:each) do
    DatabaseCleaner.clean
  end
  
end

def app
  Rack::Builder.new do    
    map "/auth" do
      run AuthApi
    end

    map "/api" do
      run AppApi
    end

    map "/" do
      run Padrino.application
    end
  end
end
