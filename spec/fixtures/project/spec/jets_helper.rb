# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['JETS_ENV'] ||= 'test'

abort("The Jets environment is running in production mode!") if Jets::Config.env == "production"

# Check for pending migrations
# TODO: Jets::Migration.maintain_test_schema!

RSpec.configure do |config|
end
