require "spec_helper"

describe Jets::Commands::RakeCommand do
  context Jets::Commands::RakeCommand do

    it "rake_tasks" do
      tasks = Jets::Commands::RakeCommand.send(:formatted_rake_tasks)
      expect(tasks).not_to be_empty
    end

    it "printing_commands" do
      commands = Jets::Commands::RakeCommand.printing_commands
      pp commands
      expect(commands).to include "db:create"
      expect(commands).to include "db:migrate"
      expect(commands).to include "webpacker"
      expect(commands).to include "webpacker:install"
      expect(commands).to include "webpacker:compile"
    end

    it "perform" do
      puts Jets::Commands::RakeCommand.perform("webpacker:verify_install")
    end
  end
end
