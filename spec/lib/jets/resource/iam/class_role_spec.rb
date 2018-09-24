describe Jets::Resource::Iam::ClassRole do
  let(:role) do
    Jets::Resource::Iam::ClassRole.new(PostsController)
  end

  context "override parent iam policy" do
    it "does not inherit from the application wide iam policy" do
      pp role
    end
  end
end