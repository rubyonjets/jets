describe Jets::Cfn::Builder::Nested do
  let(:builder) do
    Jets::Cfn::Builder::Nested.new(app_class)
  end
  let(:app_class) { PostsController }


  describe "Nested" do
    it "contains common others for classes inheriting Nested" do
      # does not yet have the compose method, it is expected to be implemented
      # by the classes inheriting Nested
      expect(builder).not_to respond_to(:compose)

      expect(builder).to respond_to(:template_path)
      expect(builder).to respond_to(:add_common_parameters)
      expect(builder).to respond_to(:add_functions)
      expect(builder).to respond_to(:add_function)
    end
  end
end
