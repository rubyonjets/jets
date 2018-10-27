module Jets::Commands
  class Import < Jets::Commands::Base
    autoload :Base, 'jets/commands/import/base'
    autoload :Rack, 'jets/commands/import/rack'
    autoload :Rail, 'jets/commands/import/rail'

    desc "rails", "imports rails project in the rack subfolder"
    long_desc Help.text('import:rails')
    def rails
      Rail.new(options).import
    end

    desc "rack", "imports generic rack project"
    long_desc Help.text('import:rack')
    def rack
      Rack.new(options).import
    end
  end
end
