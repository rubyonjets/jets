require "spec_helper"
require "jets/command/base"

describe Jets::Command do
  let(:null) { double(:null).as_null_object }
  let(:command) do
    command = Jets::Command.new(given_args)
    allow(command).to receive(:shell).and_return(null)
    command
  end

  context 'Jets::Command' do
    it "tracks subclasses" do
      # trigger classes to autload for spec
      classes = [
        Jets::Commands::Dynamodb,
        Jets::Commands::Dynamodb::Migrate,
        Jets::Commands::Main,
      ]
      expect(Jets::Command::Base.subclasses).to eq classes
    end
  end

  context 'jets help' do
    let(:given_args) { ["help"] }

    it "starts" do
      # Makes sure all the code runs to completion.  Tests:
      command.start
      expect(command).to have_received(:shell).at_least(:once)
    end

    it "thor_args removes namespace from args" do
      expect(command.thor_args).to eq(["help"])
    end

    it "full_command, namespace, meth" do
      expect(command.full_command).to be nil
      expect(command.namespace).to be nil
      expect(command.meth).to be nil
    end
  end

  context 'jets help dynamodb:migrate' do
    let(:given_args) { ["help", "dynamodb:migrate"] }

    it "thor_args removes namespace from args" do
      expect(command.thor_args).to eq(["help", "migrate"])
    end

    it "full_command, namespace, meth" do
      expect(command.full_command).to eq "dynamodb:migrate"
      expect(command.namespace).to eq "dynamodb"
      expect(command.meth).to  eq "migrate"
    end
  end

  context 'jets dynamodb:migrate' do
    let(:given_args) { ["dynamodb:migrate"] }

    it "thor_args removes namespace from args" do
      expect(command.thor_args).to eq(["migrate"])
    end

    it "full_command, namespace, meth" do
      expect(command.full_command).to eq "dynamodb:migrate"
      expect(command.namespace).to eq "dynamodb"
      expect(command.meth).to  eq "migrate"
    end
  end

  context 'jets dynamodb:migrate:down' do
    let(:given_args) { ["dynamodb:migrate:down"] }

    it "thor_args removes namespace from args" do
      expect(command.thor_args).to eq(["down"])
    end

    it "full_command, namespace, meth" do
      expect(command.full_command).to eq "dynamodb:migrate:down"
      expect(command.namespace).to eq "dynamodb:migrate"
      expect(command.meth).to  eq "down"
    end
  end

end
