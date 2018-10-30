module Jets::Commands
  autoload :Base, "jets/commands/base"
  autoload :Build, "jets/commands/build"
  autoload :Call, "jets/commands/call"
  autoload :Clean, "jets/commands/clean"
  autoload :Console, "jets/commands/console"
  autoload :Db, "jets/commands/db"
  autoload :Dbconsole, "jets/commands/dbconsole"
  autoload :Delete, "jets/commands/delete"
  autoload :Deploy, "jets/commands/deploy"
  autoload :Dynamodb, "jets/commands/dynamodb"
  autoload :Help, "jets/commands/help"
  autoload :Import, "jets/commands/import"
  autoload :Main, "jets/commands/main"
  autoload :Markdown, "jets/commands/markdown"
  autoload :New, "jets/commands/new"
  autoload :Process, "jets/commands/process"
  autoload :RakeCommand, "jets/commands/rake_command"
  autoload :RakeTasks, 'jets/commands/rake_tasks'
  autoload :Runner, 'jets/commands/runner'
  autoload :Sequence, "jets/commands/sequence"
  autoload :StackInfo, "jets/commands/stack_info"
  autoload :Url, "jets/commands/url"
  autoload :WebpackerTemplate, 'jets/commands/webpacker_template'
end
