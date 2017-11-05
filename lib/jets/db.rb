class Jets::Db < Jets::Command
  autoload :Help, 'jets/db/help'
  autoload :Migrate, 'jets/db/migrate'

  desc "migrate [path]", "Runs migrations"
  long_desc Help.migrate
  def migrate(path)
    Migrate.new(path, options).run
  end
end
