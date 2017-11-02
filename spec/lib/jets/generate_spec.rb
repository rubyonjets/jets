require "spec_helper"

describe "jets generate" do
  describe "migration" do
    it "creates a migration file" do
      command = "bin/jets generate migration posts --partition-key id:string --namespace proj-dev"
      out = execute(command)
      # pp out # uncomment to debug
      # expect(out).to include("Creating migration")
      migration_exist = File.exist?("#{Jets.root}db/migrate/posts.rb")
      expect(migration_exist).to be true
    end
  end
end
