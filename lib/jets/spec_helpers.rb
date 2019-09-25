# frozen_string_literal: true

require 'base64'

module Jets
  module SpecHelpers
    include Fixtures
    include Controllers
  end
end

unless ENV["SKIP_MIGRATION_CHECK"] == "true"
  ActiveRecord::Tasks::DatabaseTasks.db_dir = "#{Jets.root}/db"
  ActiveRecord::Migration.extend ActiveRecord::MigrationChecker
  ActiveRecord::Migration.prepare_test_db
end

require "rspec"
RSpec.configure do |c|
  c.include Jets::SpecHelpers
end
