module Jets::Commands
  class Import < Jets::Commands::Base
    autoload :Base, 'jets/commands/import/base'
    autoload :Rack, 'jets/commands/import/rack'
    autoload :Rail, 'jets/commands/import/rail'
    autoload :Sequence, 'jets/commands/import/sequence'

    long_desc Help.text('import:rails')
    register(Jets::Commands::Import::Rail, "rails", "rails", "Imports rails project in the rack subfolder")

    long_desc Help.text('import:rack')
    register(Jets::Commands::Import::Rack, "rack", "rack", "Imports rack project in the rack subfolder")
  end
end
