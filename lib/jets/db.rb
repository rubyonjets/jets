module Jets::Db ; end

# Thanks: https://makandracards.com/makandra/42521-detecting-if-a-ruby-gem-is-loaded
if File.exist?("#{Jets.root}/config/database.yml")
  require "active_record"
  specs = Gem.loaded_specs
  require "mysql2" if specs.key?('mysql2')
  require "pg" if specs.key?('pg')
end

if File.exist?("#{Jets.root}/config/dynamodb.yml")
  specs = Gem.loaded_specs
  specs.key?('dynomite')
  require "dynomite" if specs.key?('dynomite')
end
