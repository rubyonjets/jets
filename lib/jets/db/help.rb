class Jets::Db::Help
  class << self
    def migrate
<<-EOL
Runs migrations.

Example:

jets db migrate path/to/migration

jets db migrate db/migrate/posts_migration.rb
EOL
    end
  end
end
