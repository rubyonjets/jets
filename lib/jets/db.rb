# Thanks: https://makandracards.com/makandra/42521-detecting-if-a-ruby-gem-is-loaded
return unless File.exist?("#{Jets.root}config/database.yml")

require "active_record"
specs = Gem.loaded_specs
require "mysql2" if specs.key?('mysql2')
require "pg" if specs.key?('pg')
