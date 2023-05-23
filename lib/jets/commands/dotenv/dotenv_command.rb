module Jets::Command
  class DotenvCommand < Base # :nodoc:
    desc "show", "Shows evaulated dotenv values"
    long_desc Help.text('dotenv:show')
    def show
      Jets::Dotenv::Show.list
    end
  end
end
