task :environment => "db:load_config" do
  ActiveRecord::Base.establish_connection
end
