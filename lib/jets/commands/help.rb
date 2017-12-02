module Jets::Commands::Help
  class << self
    def text(namespaced_command)
      path = namespaced_command.gsub(':','/')
      path = File.expand_path("../help/#{path}.md", __FILE__)
      IO.read(path)
    end
  end
end
