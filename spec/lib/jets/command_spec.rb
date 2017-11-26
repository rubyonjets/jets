require "spec_helper"
require "jets/command/base"

describe Jets::Command do
  let(:null) { double(:null).as_null_object }
  let(:command_klass) do
    allow(Jets::Command).to receive(:shell).and_return(null)
    Jets::Command
  end

  it "help" do
    # just makes sure all the code runs to completion
    command_klass.start(["help"])
    expect(Jets::Command).to have_received(:shell).at_least(:once)
  end

  it "thor_args moves namespace from args" do
    args = command_klass.thor_args(["help"])
    expect(args).to eq(["help"])

    args = command_klass.thor_args(["help", "dynamodb:migrate"])
    expect(args).to eq(["help", "migrate"])

    args = command_klass.thor_args(["dynamodb:migrate"])
    expect(args).to eq(["migrate"])
  end

  it "full_command" do
    command = command_klass.full_command(["help"])
    expect(command).to be nil

    command = command_klass.full_command(["help", "dynamodb:migrate"])
    expect(command).to eq "dynamodb:migrate"

    command = command_klass.full_command(["dynamodb:migrate"])
    expect(command).to eq "dynamodb:migrate"
  end

  it "namespace_and_meth" do
    namespace, meth = command_klass.namespace_and_meth("help")
    expect(namespace).to be nil
    expect(meth).to eq "help"

    namespace, meth = command_klass.namespace_and_meth("dynamodb:migrate")
    expect(namespace).to eq "dynamodb"
    expect(meth).to eq "migrate"

    namespace, meth = command_klass.namespace_and_meth("dynamodb:migrate:down")
    expect(namespace).to eq "dynamodb:migrate"
    expect(meth).to eq "down"
  end
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
