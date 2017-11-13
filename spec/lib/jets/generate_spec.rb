require "spec_helper"

describe "jets generate" do
  describe "migration" do
    it "creates a migration file" do
      command = "bin/jets dynamodb generate create_posts --partition-key id:string"
      out = execute(command)
      # pp out # uncomment to debug
      # expect(out).to include("Creating migration")
      migration_path = Dir.glob("#{DynamodbModel.app_root}dynamodb/migrate/*").first
      migration_exist = File.exist?(migration_path)
      expect(migration_exist).to be true
    end
  end
end
