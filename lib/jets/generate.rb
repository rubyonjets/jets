class Jets::Generate < Jets::Command
  autoload :Help, 'jets/generate/help'
  autoload :Migration, 'jets/generate/migration'
  autoload :Scaffold, 'jets/generate/scaffold'

  class_option :verbose, type: :boolean
  class_option :noop, type: :boolean

  desc "migration [name]", "Creates a migration for a DynamoDB table"
  long_desc Help.migration
  option :partition_key, default: "id:string"
  def migration(name)
    Migration.new(name, options).run
  end

  desc "scaffold [name]", "Creates a CRUD scaffold"
  long_desc Help.scaffold
  def scaffold(name)
    Scaffold.new(name, options).run
  end
end
