require "spec_helper"

describe Jets::Commands::RakeCommand do
  context Jets::Commands::RakeCommand do

    it "rake_tasks" do
      tasks = Jets::Commands::RakeCommand.send(:formatted_rake_tasks)
      expect(tasks).not_to be_empty
    end

    it "namespaced_commands" do
      commands = Jets::Commands::RakeCommand.namespaced_commands
      # pp commands
      expect(commands).to include "db:create"
      expect(commands).to include "db:migrate"
      expect(commands).to include "webpacker"
      expect(commands).to include "webpacker:install"
      expect(commands).to include "webpacker:compile"
    end

    it "perform" do
      # Wonder how to better test this without adding a def rake stub
      null = double(:null).as_null_object
      allow(Jets::Commands::RakeCommand).to receive(:rake).and_return(null)
      Jets::Commands::RakeCommand.perform("webpacker:verify_install", {})
      expect(Jets::Commands::RakeCommand).to have_received(:rake).at_least(:once)
    end
  end
end
