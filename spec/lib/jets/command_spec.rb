require "spec_helper"
require "jets/command/base"

describe Jets::Command do
  let(:null) { double(:null).as_null_object }
  let(:command) do
    command = Jets::Command.new(given_args)
    allow(command).to receive(:shell).and_return(null)
    command
  end

  context '"help"' do
    let(:given_args) { ["help"] }

    it "starts" do
      # just makes sure all the code runs to completion
      command.start()
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

  context '"help", "dynamodb:migrate"' do
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

  context '"dynamodb:migrate"' do
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

  # it "namespace_and_meth" do
  #   namespace, meth = command.namespace_and_meth("help")
  #   expect(namespace).to be nil
  #   expect(meth).to eq "help"

  #   namespace, meth = command.namespace_and_meth("dynamodb:migrate")
  #   expect(namespace).to eq "dynamodb"
  #   expect(meth).to eq "migrate"

  #   namespace, meth = command.namespace_and_meth("dynamodb:migrate:down")
  #   expect(namespace).to eq "dynamodb:migrate"
  #   expect(meth).to eq "down"
  # end
end

# full_command, args = [], **config

# command = full_command
# args = args.dup
# command = args.dup.shift
# pp given_args

# puts "full_command #{full_command}"
# puts "command #{command}"
# puts "args #{args.inspect}"
# puts "config #{config.inspect}"
# puts ""
