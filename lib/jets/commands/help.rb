module Jets::Commands::Help
  class << self
    def text(meth)
      # caller[0]: lib/jets/commands/main.rb:57:in `<class:Main>'
      # path: help/main/dbconsole.md
      class_path = caller[0].split(':').first
      class_path = class_path.sub(%r{.*jets/commands/},'').sub(/\.rb$/,'') # just "main" now
      path = File.expand_path("../help/#{class_path}/#{meth}.md", __FILE__)
      IO.read(path)
    end
  end
end
