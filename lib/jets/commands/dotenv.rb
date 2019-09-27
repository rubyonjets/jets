module Jets::Commands
  class Dotenv < Jets::Commands::Base
    desc "show", "Shows evaulated dotenv values"
    long_desc Help.text('dotenv:show')
    def show
      Jets::Dotenv::Show.list
    end
  end
end
