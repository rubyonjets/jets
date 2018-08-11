describe Jets::Commands::Markdown::Creator do
  let(:creator) do
    Jets::Commands::Markdown::Creator.new
  end

  context "markdown" do
    # leaving this spec around in case useful for debugging
    it "creates help files as markdown" do
      # creator.create_all # comment out to generate docs with specs and debug quickly
    end

    it "examples of debugging" do
      # puts "Jets::Commands::Base.namespaced_commands"
      # puts Jets::Commands::Base.namespaced_commands

      # pp Jets::CLI.new([full_command]).lookup(full_command)
      # pp Jets::CLI.new.lookup("dynamodb")

      # c = Jets::Commands::Main.commands.first.last
      # puts "name: #{c.name}"
      # puts "desc: #{c.description}"
      # puts "long desc: #{c.long_description}"

      # c = Jets::Commands::Dynamodb.commands.first.last
      # puts "name: #{c.name}"
      # puts "desc: #{c.description}"
      # puts "long desc: #{c.long_description}"
    end
  end
end
