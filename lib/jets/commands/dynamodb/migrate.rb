class Jets::Commands::Dynamodb::Migrate < Jets::Commands::Base
  desc "down", "Runs migrations down"
  # desc "migrate:down [path]", "Runs migrations down"
  # long_desc Help.migrate
  def down#(path)
    # Migrate.new(path, options).run
    puts "Jets::Commands::Dynamodb::Down ran"
  end
end
