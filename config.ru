#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

use Rack::Session::Dalli, :namespace => 'rack:session'

map "/auth" do
  run AuthApi
end

map "/api" do
  run AppApi
end

map "/" do
  run Padrino.application
end
