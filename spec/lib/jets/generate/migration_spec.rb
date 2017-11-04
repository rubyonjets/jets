require "spec_helper"

describe "migration" do
  before(:each) do
    FileUtils.rm_rf("#{Jets.root}db/migrate")
  end

  let(:migration) do
    Jets::Generate::Migration.new("comments", {partition_key: "post_id:string:hash", sort_key: "created_at:string:range", quiet: true})
  end

  it "generates migration file in db/migrate" do
    expect(migration.table_name).to eq "#{Jets.config.project_namespace}-comments"

    migration.create

    migration_exist = File.exist?("#{Jets.root}db/migrate/comments.rb")
    expect(migration_exist).to be true
  end
end
