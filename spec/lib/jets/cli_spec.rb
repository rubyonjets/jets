describe Jets::CLI do
  let(:command) { Jets::CLI.new(given_args) }

  context Jets::CLI do
    it "tracks subclasses" do
      # trigger classes to autload for spec
      classes = [
        Jets::Commands::Dynamodb,
        Jets::Commands::Dynamodb::Migrate,
        Jets::Commands::Main,
      ]
      expect(Jets::Commands::Base.subclasses).to eq classes
    end

    it "thor_tasks" do
      tasks = Jets::CLI.thor_tasks
      # pp tasks
    end
  end

  context 'jets help' do
    let(:given_args) { ["help"] }

    it "prints main help menu" do
      allow(command).to receive(:main_help)
      command.start
      expect(command).to have_received(:main_help).at_least(:once)
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

  context 'jets --whatever' do
    let(:given_args) { ["--whatever"] }

    it "full_command, namespace, meth" do
      expect(command.full_command).to be nil
      expect(command.namespace).to be nil
      expect(command.meth).to be nil
    end
  end

  context 'jets routes - command without namespace' do
    let(:given_args) { ["routes"] }

    it "thor_args removes namespace from args" do
      expect(command.thor_args).to eq(["routes"])
    end

    it "full_command, namespace, meth" do
      expect(command.full_command).to eq "routes"
      expect(command.namespace).to be nil
      expect(command.meth).to eq "routes"
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

  context 'jets dynamodb:migrate help' do
    let(:given_args) { ["dynamodb:migrate", "help"] }

    it "thor_args moves help command to the front" do
      expect(command.thor_args).to eq(["help", "migrate"]) # help in front
    end

    it "full_command, namespace, meth" do
      expect(command.full_command).to eq "dynamodb:migrate"
      expect(command.namespace).to eq "dynamodb"
      expect(command.meth).to  eq "migrate"
    end
  end

  context 'jets dynamodb:migrate --help' do
    let(:given_args) { ["dynamodb:migrate", "help"] }

    it "thor_args moves help command to the front" do
      expect(command.thor_args).to eq(["help", "migrate"]) # help in front
    end

    it "full_command, namespace, meth" do
      expect(command.full_command).to eq "dynamodb:migrate"
      expect(command.namespace).to eq "dynamodb"
      expect(command.meth).to  eq "migrate"
    end
  end

  context 'jets --help dynamodb:migrate' do
    let(:given_args) { ["dynamodb:migrate", "help"] }

    it "thor_args moves help command to the front" do
      expect(command.thor_args).to eq(["help", "migrate"]) # help in front
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
