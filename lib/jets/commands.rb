module Jets::Commands
  autoload :Base, "jets/commands/base"
  autoload :Build, "jets/commands/build"
  autoload :Deploy, "jets/commands/deploy"
  autoload :Delete, "jets/commands/delete"
  autoload :New, "jets/commands/new"
  autoload :Call, "jets/commands/call"
  autoload :Console, "jets/commands/console"
  autoload :Db, "jets/commands/db"
  autoload :Dynamodb, "jets/commands/dynamodb"
  autoload :Main, "jets/commands/main"
  autoload :Process, "jets/commands/process"
  autoload :RakeCommand, "jets/commands/rake_command"
  autoload :RakeTasks, 'jets/commands/rake_tasks'
  autoload :WebpackerTemplate, 'jets/commands/webpacker_template'
  autoload :Sequence, "jets/commands/sequence"
  autoload :FirstRun, "jets/commands/first_run"
end
