class Jets::CLI
  module Help
    extend self
    def text(namespaced_command)
      file = namespaced_command.to_s.tr(":", "/")
      path = File.expand_path("../help/#{file}.md", __FILE__)
      return IO.read(path) if File.exist?(path)

      # Also look up for a help folder within the current command folder
      called_from = caller(1..1).first.split(":").first
      unnamespaced_command = namespaced_command.to_s.split(":").last
      path = File.expand_path("../help/#{unnamespaced_command}.md", called_from)
      IO.read(path) if File.exist?(path)
    end
  end
end
