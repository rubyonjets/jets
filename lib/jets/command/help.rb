module Jets::Command
  class Help
    class << self
      def text(namespaced_command)
        file = namespaced_command.to_s.gsub(':','/')
        path = File.expand_path("../help/#{file}.md", __FILE__)
        return IO.read(path) if File.exist?(path)

        # Also look up for a help folder within the current command folder
        called_from = caller.first.split(':').first
        unnamespaced_command = namespaced_command.to_s.split(':').last
        path = File.expand_path("../help/#{unnamespaced_command}.md", called_from)
        return IO.read(path) if File.exist?(path)
      end
    end
  end
end
