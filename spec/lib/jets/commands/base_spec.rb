require "spec_helper"

describe Jets::Commands::Base do
  let(:null) { double(:null).as_null_object }
  let(:command) do
    command = Jets::Commands::Base.new(given_args)
    allow(command).to receive(:shell).and_return(null)
    command
  end

  context Jets::Commands::Base do
    it "task_full_names" do
      full_names = Jets::Commands::Base.task_full_names
      expect(full_names).to include "build"
      expect(full_names).to include "call"
      expect(full_names).to include "routes"
      expect(full_names).to include "dynamodb:generate"
      expect(full_names).to include "dynamodb:migrate:down"
      expect(full_names).to include "process:controller"
    end
  end
end
